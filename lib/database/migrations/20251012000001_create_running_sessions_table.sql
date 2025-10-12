-- 러닝 세션 테이블 생성
-- GPS 기반 거리, 페이스, 시간, 고도 추적
CREATE TABLE IF NOT EXISTS running_sessions (
    -- 기본 정보
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    
    -- 시간 정보
    start_time TIMESTAMP WITH TIME ZONE NOT NULL,
    end_time TIMESTAMP WITH TIME ZONE,
    duration INTEGER, -- 초 단위 (실제 러닝 시간, 일시정지 제외)
    total_duration INTEGER, -- 초 단위 (일시정지 포함 전체 시간)
    
    -- 거리 및 속도 정보
    distance DECIMAL(10, 2), -- 미터 단위
    avg_pace DECIMAL(10, 2), -- 초/km (평균 페이스)
    max_speed DECIMAL(10, 2), -- km/h (최고 속도)
    avg_speed DECIMAL(10, 2), -- km/h (평균 속도)
    
    -- 칼로리 및 건강 정보
    calories INTEGER, -- 소모 칼로리
    avg_heart_rate INTEGER, -- 평균 심박수 (bpm)
    max_heart_rate INTEGER, -- 최대 심박수 (bpm)
    
    -- GPS 및 고도 데이터
    gps_data JSONB, -- GPS 좌표 배열 [{lat, lng, timestamp, altitude, speed}, ...]
    elevation_gain DECIMAL(10, 2), -- 누적 상승 고도 (m)
    elevation_loss DECIMAL(10, 2), -- 누적 하강 고도 (m)
    
    -- 상태 및 메타데이터
    status TEXT CHECK (status IN ('in_progress', 'paused', 'completed', 'cancelled')) DEFAULT 'in_progress',
    weather_condition TEXT, -- 날씨 정보 (선택)
    temperature DECIMAL(5, 2), -- 온도 (°C)
    notes TEXT, -- 사용자 메모
    
    -- 타임스탬프
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- 인덱스를 위한 제약조건
    CHECK (start_time <= end_time),
    CHECK (distance >= 0),
    CHECK (duration >= 0)
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX idx_running_sessions_user_id ON running_sessions(user_id);
CREATE INDEX idx_running_sessions_start_time ON running_sessions(start_time DESC);
CREATE INDEX idx_running_sessions_status ON running_sessions(status);
CREATE INDEX idx_running_sessions_user_start ON running_sessions(user_id, start_time DESC);

-- RLS (Row Level Security) 활성화
ALTER TABLE running_sessions ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 사용자는 자신의 세션만 조회/생성/수정/삭제 가능
CREATE POLICY "Users can view own sessions" ON running_sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own sessions" ON running_sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own sessions" ON running_sessions
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own sessions" ON running_sessions
    FOR DELETE USING (auth.uid() = user_id);

-- updated_at 자동 업데이트 트리거
CREATE TRIGGER update_running_sessions_updated_at
    BEFORE UPDATE ON running_sessions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 코멘트 추가 (문서화)
COMMENT ON TABLE running_sessions IS '사용자의 러닝 세션 기록';
COMMENT ON COLUMN running_sessions.gps_data IS 'GPS 좌표 배열: [{lat, lng, timestamp, altitude, speed}, ...]';
COMMENT ON COLUMN running_sessions.avg_pace IS '평균 페이스 (초/km)';
COMMENT ON COLUMN running_sessions.duration IS '실제 러닝 시간 (초, 일시정지 제외)';
COMMENT ON COLUMN running_sessions.total_duration IS '전체 시간 (초, 일시정지 포함)';

