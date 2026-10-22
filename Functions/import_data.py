"""Import GEIH data from this repository.

Python counterpart of Functions/import_data.R. The result is a nested
dictionary {year: {month: pandas.DataFrame}} and, when name_list is given,
it is also assigned to the caller's global namespace.

Every field is read as text first and only converted to a number when that
cannot lose information (values with leading zeros, such as "01" or "05",
stay as text).
"""

import inspect
import sys
import urllib.parse

import pandas as pd

__all__ = ["import_data"]

_NUMBER_PATTERN = r"^[+-]?(0|[1-9]\d*)(\.\d+)?$"


def import_data(name_list, name_directory, names_years, names_months, root):
    """Load the requested months into a nested dictionary.

    Parameters
    ----------
    name_list : str or None
        Name of the variable created in the caller's global namespace.
        Use None to only return the dictionary.
    name_directory : str
        Base directory or URL. A trailing "/" is added if missing.
    names_years : sequence of str
    names_months : sequence of str
    root : str
        File name. Use spaces for local paths ("Fuerza de trabajo.CSV")
        and percent-encoded spaces for URLs ("Fuerza%20de%20trabajo.CSV").

    Returns
    -------
    dict
        {year: {month: DataFrame}} with only the months that were found.
    """
    if isinstance(names_years, str):
        names_years = [names_years]
    if isinstance(names_months, str):
        names_months = [names_months]
    name_directory = str(name_directory)
    root = str(root)
    if not name_directory.endswith("/"):
        name_directory += "/"

    data = {}
    missing_months = []

    for year in names_years:
        data[year] = {}
        for month in names_months:
            source = _build_source(name_directory, year, month, root)
            try:
                table = pd.read_csv(
                    source,
                    sep=";",
                    encoding="utf-8",
                    dtype=str,
                    skipinitialspace=True,
                    low_memory=False,
                )
            except (OSError, UnicodeDecodeError, ValueError):
                missing_months.append(f"{year} {month}")
                continue
            data[year][month] = _coerce_types(table)

    if name_list:
        frame = inspect.currentframe()
        try:
            if frame is not None and frame.f_back is not None:
                frame.f_back.f_globals[name_list] = data
        finally:
            del frame

    if missing_months:
        print("Meses no disponibles: " + ", ".join(missing_months), file=sys.stderr)

    return data


def _build_source(name_directory, year, month, root):
    source = f"{name_directory}{year}/{month}/{root}"
    if source.startswith(("http://", "https://")):
        parts = urllib.parse.urlsplit(source)
        path = urllib.parse.quote(parts.path, safe="/%")
        return urllib.parse.urlunsplit(
            (parts.scheme, parts.netloc, path, parts.query, parts.fragment)
        )
    return source


def _coerce_types(data):
    for column in data.columns:
        series = data[column]
        values = series.dropna()
        if values.empty:
            continue
        if values.str.match(_NUMBER_PATTERN).all():
            numbers = pd.to_numeric(series, errors="coerce")
            if (numbers.dropna() % 1 == 0).all():
                data[column] = numbers.astype("Int64")
            else:
                data[column] = numbers.astype("float64")
        elif values.isin(["TRUE", "FALSE"]).all():
            data[column] = series.map({"TRUE": True, "FALSE": False}).astype("boolean")
    return data
