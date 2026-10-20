from typing import Tuple
# Импортируем структуру данных, чтобы знать, с чем работаем
from sbor_dannih import IndicatorData


# --- РАЗБИВАЕМ НА МЕЛКИЕ, ПОНЯТНЫЕ ФУНКЦИИ ---

def _get_sma_trend(data: IndicatorData) -> int:
    """Возвращает 1 (рост), -1 (падение), 0 (флэт)"""
    if data.last_sma_10_3 < data.last_sma_10_2 < data.last_sma_10_1:
        return 1
    if data.last_sma_10_1 < data.last_sma_10_2 < data.last_sma_10_3:
        return -1
    return 0


def _get_volume_score(data: IndicatorData) -> float:
    """Возвращает только оценку объема"""
    v, m = data.volume, data.mean_volume
    if v > 2 * m: return 1.0
    if v > m: return 0.5
    if v >= 0.5 * m: return 0.0
    return -1.0


# --- ГЛАВНАЯ ФУНКЦИЯ ОЦЕНКИ (собирает всё воедино) ---
def evaluate_telega_day_hour(tf_name: str, data: IndicatorData) -> Tuple[bool, bool, float, str]:
    """Теперь эта функция читается как обычный текст, а не как стена кода"""

    # 1. Получаем факты через мелкие функции
    trend_dir = _get_sma_trend(data)
    sma_up = trend_dir == 1
    sma_down = trend_dir == -1
    vol_score = _get_volume_score(data)

    # 2. Считаем Score (логика та же самая, но код чище)
    score = 0.0
    score += 0.3 * trend_dir
    score += 0.2 * (1 if data.last_rsi > data.prev_rsi_3 else -1 if data.last_rsi < data.prev_rsi_3 else 0)
    score += 0.2 * (1 if data.last_macd > data.prev_macd_3 else -1 if data.last_macd < data.prev_macd_3 else 0)
    score += 0.3 * vol_score * trend_dir

    # 3. Логика принятия решений
    is_buy, is_sell, desc = False, False, ""

    if tf_name == "day":
        if sma_up:
            is_buy, desc = True, "SMA10↑; (тут краткое описание)"
        elif sma_down:
            is_sell, desc = True, "SMA10↓; (тут краткое описание)"

    elif tf_name == "hour":
        # Условия "Дно" теперь читаются легко, потому что мы вынесли сложную логику MACD
        # в понятные переменные (в полном коде выше я это показал)
        is_macd_bottoming = data.prev_macd_3 < data.prev_macd < data.last_macd < 0
        if data.close < data.mid_bollinger and is_macd_bottoming:
            is_buy, desc = True, "🕳️ДНО🕳️; (описание)"

    return is_buy, is_sell, score, desc