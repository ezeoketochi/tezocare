FREQUENCY_MULTIPLIERS: dict[str, int | None] = {
    "OD": 1,
    "BD": 2,
    "TDS": 3,
    "QDS": 4,
    "PRN": None,
    "STAT": 1,
    "ON": 1,
    "OM": 1,
}


def compute_total_quantity(
    dose_amount: float | None,
    frequency_code: str | None,
    duration_amount: int | None,
) -> int | None:
    if dose_amount is None or duration_amount is None:
        return None
    multiplier = FREQUENCY_MULTIPLIERS.get(frequency_code or "") if frequency_code else None
    if multiplier is None:
        return None
    return int(dose_amount * multiplier * duration_amount)


def build_sig_string(
    dose_amount: float | None = None,
    dose_unit: str = "",
    route: str = "",
    frequency: str = "",
    duration_amount: int | None = None,
    duration_unit: str = "",
    instructions: str | None = None,
) -> str:
    parts: list[str] = []
    if dose_amount is not None:
        unit_part = f"{dose_unit}(s)" if dose_unit else ""
        parts.append(f"{dose_amount} {unit_part}".strip())
    if route:
        parts.append(route)
    if frequency:
        parts.append(frequency)
    if duration_amount is not None and duration_unit:
        parts.append(f"for {duration_amount} {duration_unit}")
    if instructions:
        parts.append(f"({instructions})")
    return " ".join(parts)
