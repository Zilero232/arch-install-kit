from typing import List, Optional
from dataclasses import dataclass
from enum import Enum
import asyncio

from utils import SystemUtils


class PackageManagerType(Enum):
    PACMAN = "pacman"
    AUR = "aur"


@dataclass
class PackageResult:
    success: bool
    package: str
    message: str
    manager: PackageManagerType


class PackageManager:
    def __init__(self, logger):
        self.logger = logger

    async def update_system(self) -> bool:
        try:
            self.logger.info("Updating system packages...")

            # Run system update command
            success, output = await SystemUtils.run_command(
                "sudo pacman -Syu --noconfirm"
            )

            if success:
                self.logger.success("System updated successfully")

                return True
            else:
                self.logger.error(f"Failed to update system: {output}")

                return False

        except Exception as e:
            self.logger.error(f"Error updating system: {e}")
            
            return False

    # Install multiple packages
    async def install_packages(
        self,
        packages: List[str],
        manager: PackageManagerType = PackageManagerType.PACMAN,
    ) -> List[PackageResult]:
        # Create tasks for parallel installation
        tasks = [
            self._install_package(pkg, manager) 
            for pkg in packages
        ]

        # Run all tasks in parallel
        results = await asyncio.gather(*tasks)

        # Log installation results
        for result in results:
            if result.success:
                self.logger.success(f"Installed {result.package}")
            else:
                self.logger.error(
                    f"Failed to install {result.package}: {result.message}"
                )

        return results

    # Install a single package
    async def _install_package(
        self, package: str, manager: PackageManagerType
    ) -> PackageResult:
        try:
            # Get installation command for package manager
            cmd = self._get_install_command(package, manager)

            # Return package result if package manager is not supported
            if not cmd:
                return PackageResult(
                    False,
                    package,
                    f"Unsupported package manager: {manager.value}",
                    manager,
                )

            # Run installation process
            success, output = await SystemUtils.run_command(cmd)

            # Return package result
            return PackageResult(success, package, output, manager)

        except Exception as e:
            self.logger.error(f"Error installing {package}: {e}")

            return PackageResult(False, package, str(e), manager)

    # Get installation command based on package manager
    def _get_install_command(
        self, package: str, manager: PackageManagerType
    ) -> Optional[str]:
        commands = {
            PackageManagerType.PACMAN: f"sudo pacman -Syu --noconfirm {package}",
            PackageManagerType.AUR: f"yay -S --noconfirm {package}",
        }

        return commands.get(manager)
