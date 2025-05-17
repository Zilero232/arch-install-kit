import logging
from pathlib import Path
from typing import Optional
from enum import Enum

class LogLevel(Enum):
    INFO = "ℹ️"
    SUCCESS = "✅"
    WARNING = "⚠️"
    ERROR = "❌"

class Logger:
    def __init__(self, log_file: Optional[Path] = None):
        # Setup logger
        self.logger = logging.getLogger("arch_installer")
        self.logger.setLevel(logging.INFO)
        
        # Message format
        formatter = logging.Formatter(
            '%(asctime)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        
        # Output to console
        console = logging.StreamHandler()
        console.setFormatter(formatter)
        self.logger.addHandler(console)
        
        # Output to file (if specified)
        if log_file:
            file = logging.FileHandler(log_file)
            file.setFormatter(formatter)
            self.logger.addHandler(file)

    def _log(self, level: LogLevel, message: str) -> None:
        self.logger.info(f"{level.value} {message}")

    def info(self, message: str) -> None:
        self._log(LogLevel.INFO, message)

    def success(self, message: str) -> None:
        self._log(LogLevel.SUCCESS, message)

    def warning(self, message: str) -> None:
        self._log(LogLevel.WARNING, message)

    def error(self, message: str) -> None:
        self._log(LogLevel.ERROR, message)

def setup_logger(log_file: Optional[Path] = None) -> Logger:
    return Logger(log_file)