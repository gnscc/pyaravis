import os

import gi


def append_path(key: str, path: str) -> None:
    """
    Append path value to environment variable key

    Parameters
    ----------
    key : str
        Environment variable key
    path : str
        Path value to append
    """

    if key in os.environ:
        os.environ[key] = os.environ[key] + os.pathsep + path
    else:
        os.environ[key] = path


lib_path = os.path.join(os.path.dirname(__file__), 'lib')

append_path('LD_LIBRARY_PATH', lib_path)
append_path('GI_TYPELIB_PATH', lib_path)

gi.require_version('Aravis', '__REPLACE_VERSION__')
from gi.repository import Aravis  # noqa: E402
