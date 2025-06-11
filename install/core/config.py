from enum import Enum
from dataclasses import dataclass
from pathlib import Path
from typing import Dict, List, Optional, Any
import yaml

from .package_manager import PackageManagerType
from utils import SystemUtils

# Enums for type safety
class DotfileType(Enum):
    FILE = "file"
    DIR = "dir"

class DriverType(Enum):
    NVIDIA = "nvidia"
    INTEL = "intel"
    RADEON = "radeon"
    NONE = "none"

# Data classes for configuration
@dataclass
class DriverChoice:
    name: str
    description: str

@dataclass
class InstallOption:
    name: str
    description: str
    default: bool
    type: str = "boolean"
    choices: Optional[List[DriverChoice]] = None

@dataclass
class DotfileConfig:
    source: str
    dest: str
    type: DotfileType

class Config:
    def __init__(self, config_dir: Path):
        self.config_dir = config_dir
        self._configs: Dict[str, Any] = {}

        self._load_configs()

    def _load_configs(self) -> None:
        # Load all configuration files
        config_files = {
            "prompts": "prompts.yaml",
            "paths": "paths.yaml",
            "packages": "packages.yaml",
            "folders": "folders.yaml"
        }
        
        self._configs = {
            name: self._load_yaml(filename)
            for name, filename in config_files.items()
        }
        
        self._parse_configs()

    def _load_yaml(self, filename: str) -> Dict:
        # Load and validate YAML file
        try:
            with open(self.config_dir / filename) as f:
                return yaml.safe_load(f)
        except FileNotFoundError:
            raise Exception(f"Config file not found: {filename}")
        except yaml.YAMLError as e:
            raise Exception(f"Invalid YAML format in {filename}: {e}")

    def _parse_configs(self) -> None:
        # Parse installation options
        self.install_options = [
            self._create_install_option(opt)
            for opt in self._configs["prompts"]["install_options"]
        ]

        # Parse dotfiles configuration
        self.dotfiles = {
            name: DotfileConfig(
                source=config["source"],
                dest=config["dest"],
                type=DotfileType(config["type"])
            )
            for name, config in self._configs["paths"]["dotfiles"].items()
        }

        # Parse paths and folders
        self.default_folders = self._configs["folders"]["default_folders"]

    def _create_install_option(self, opt: Dict) -> InstallOption:
        # Create InstallOption from raw config
        if opt["type"] == "choice":
            choices = [
                DriverChoice(**choice) 
                for choice in opt["choices"]
            ]

            return InstallOption(
                name=opt["name"],
                description=opt["description"],
                default=opt.get("default", True),
                type="choice",
                choices=choices
            )
        
        return InstallOption(**opt)

    # Public methods for prompts
    def get_install_options(self) -> List[InstallOption]:
        return self.install_options

    def get_all_dotfiles(self) -> Dict[str, DotfileConfig]:
        return self.dotfiles

    # Public methods for folders
    def get_default_folders(self) -> List[Path]:
        return [
            SystemUtils.get_path(folder) 
            for folder in self.default_folders
        ]

    # Public methods for packages
    def get_packages(self, manager: PackageManagerType) -> List[str]:
        packages = self._configs["packages"]["packages"][manager.value]
        
        return sum((
            packages.get("system", []),
            packages.get("desktop", []),
            packages.get("dev", []),
            packages.get("apps", [])
        ), [])

    def get_driver_packages(self, driver_type: DriverType) -> List[str]:
        if driver_type == DriverType.NONE:
            return []
        
        return self._configs["packages"]["packages"]["drivers"][driver_type.value]