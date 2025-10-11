# Google Sign-In Nonce 오류 수정

## 🚨 오류 증상

```
AuthApiException(
  message: Passed nonce and nonce in id_token should either both exist or not.,
  statusCode: 400,
  code: null
)
```

Google ID Token을 성공적으로 획득했지만, Supabase `signInWithIdToken` 호출 시 nonce 관련 오류가 발생합니다.

## 🔍 원인 분석

### 문제의 핵심

Supabase는 **nonce 일관성**을 검증합니다:

- ID Token에 `nonce` 클레임이 **있으면** → `signInWithIdToken`에도 `nonce` 파라미터 필수
- ID Token에 `nonce` 클레임이 **없으면** → `signInWithIdToken`에 `nonce` 파라미터 생략

### Google Sign-In의 nonce 처리

Google Sign-In SDK는 기본적으로:

1. **nonce를 생성하지 않음** (대부분의 경우)
2. 일부 설정에 따라 자동으로 nonce를 생성할 수 있음
3. ID Token에 nonce가 포함되면 Supabase에도 전달해야 함

## ✅ 해결 방법

### 1. Supabase 버전 업데이트

```yaml
# pubspec.yaml
dependencies:
  supabase_flutter: ^2.10.0 # 이전: ^2.8.0
```

### 2. ID Token에서 nonce 자동 추출

```dart
/// 모바일용 Google 로그인 (네이티브 + ID Token)
static Future<bool> _signInWithGoogleMobile() async {
  // 1. Google Sign-In
  final googleUser = await _googleSignIn.signIn();
  final googleAuth = await googleUser.authentication;
  final idToken = googleAuth.idToken;

  // 2. ID Token에서 nonce 추출
  String? nonce;
  try {
    final parts = idToken.split('.');
    if (parts.length == 3) {
      final payload = parts[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      nonce = json['nonce'] as String?;
    }
  } catch (e) {
    developer.log('ID Token 디코딩 실패: $e');
  }

  // 3. nonce 유무에 따라 다르게 호출
  final response = nonce != null
      ? await client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
          nonce: nonce,  // nonce 포함
        )
      : await client.auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,  // nonce 생략
        );
}
```

## 🔧 전체 코드 구조

### imports 추가

```dart
import 'dart:math';
import 'dart:convert';
```

### 핵심 로직

1. **ID Token 디코딩**: JWT 토큰을 Base64 디코딩하여 payload 추출
2. **nonce 클레임 확인**: `json['nonce']` 존재 여부 확인
3. **조건부 호출**: nonce 유무에 따라 다른 파라미터로 `signInWithIdToken` 호출

## 📊 동작 흐름

### Case 1: nonce가 없는 경우 (대부분)

```
Google Sign-In → ID Token (nonce 없음)
→ Supabase signInWithIdToken(nonce 생략)
→ ✅ 로그인 성공
```

### Case 2: nonce가 있는 경우

```
Google Sign-In → ID Token (nonce 포함)
→ ID Token 디코딩 → nonce 추출
→ Supabase signInWithIdToken(nonce 포함)
→ ✅ 로그인 성공
```

## 🧪 테스트

```bash
flutter test test/unit/services/google_auth_platform_test.dart
```

**결과**: ✅ 3/3 테스트 통과

## 🔍 디버깅 로그

### 성공적인 로그인

```
[GoogleAuthService] 모바일 네이티브 로그인 시작
[GoogleAuthService] Google 사용자 인증 완료: user@gmail.com
[GoogleAuthService] Google ID Token 획득 완료
[GoogleAuthService] ID Token에 nonce 없음
[GoogleAuthService] Supabase 로그인 완료: user@gmail.com
```

또는

```
[GoogleAuthService] 모바일 네이티브 로그인 시작
[GoogleAuthService] Google 사용자 인증 완료: user@gmail.com
[GoogleAuthService] Google ID Token 획득 완료
[GoogleAuthService] ID Token에서 nonce 발견: abc123def4...
[GoogleAuthService] Supabase 로그인 완료: user@gmail.com
```

## ⚠️ 주의사항

### 1. base64 패키지 사용

`base64.normalize()`을 사용하여 Base64 URL-safe 디코딩을 처리합니다.

### 2. 에러 처리

ID Token 디코딩 실패 시에도 로그인을 계속 시도합니다 (nonce 없는 것으로 간주).

### 3. Supabase 버전

`supabase_flutter: ^2.10.0` 이상 사용을 권장합니다.

## 🎯 왜 이런 문제가 발생하나?

### Apple Sign In과의 차이

- **Apple Sign In**: nonce가 **필수**

  ```dart
  final rawNonce = generateNonce();
  // Apple Sign In with rawNonce
  // ID Token에 nonce 포함됨
  await client.auth.signInWithIdToken(
    provider: OAuthProvider.apple,
    idToken: idToken,
    nonce: rawNonce,  // 필수!
  );
  ```

- **Google Sign In**: nonce가 **선택적**
  ```dart
  // Google Sign In (nonce 자동 생성 안 함)
  // ID Token에 nonce 없음
  await client.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    // nonce 생략 가능
  );
  ```

### Supabase의 검증 로직

Supabase는 보안을 위해 nonce 일관성을 검증합니다:

```python
# Supabase 백엔드 의사 코드
if id_token.has_nonce() and not request.has_nonce():
    raise AuthApiException("nonce mismatch")
if not id_token.has_nonce() and request.has_nonce():
    raise AuthApiException("nonce mismatch")
```

## 📚 관련 문서

- [Supabase Auth - Google Sign In](https://supabase.com/docs/guides/auth/social-login/auth-google)
- [JWT.io - Token Inspector](https://jwt.io/)
- [Google Sign-In Flutter Plugin](https://pub.dev/packages/google_sign_in)

## 🎓 학습 포인트

1. **JWT 구조 이해**: Header.Payload.Signature 형식
2. **Base64 URL-safe 디코딩**: 패딩 처리의 중요성
3. **OAuth 보안**: nonce의 역할 (replay attack 방지)
4. **플랫폼별 차이**: Apple vs Google Sign-In의 nonce 처리 차이

---

**수정 완료**: 2025-10-11  
**오류 해결**: ID Token에서 nonce 자동 추출 후 조건부 전달 ✅
