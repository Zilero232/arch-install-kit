from pathlib import Path

from utils import SystemUtils
from ui import InstallOptions

from .config import Config, DotfileType, DriverType
from .package_manager import PackageManager, PackageManagerType


class SystemInstaller:
    # System installer for Arch Linux
    def __init__(self, config: Config, package_manager: PackageManager, logger):
        self.config = config
        self.package_manager = package_manager
        self.logger = logger

    async def install(self, options: InstallOptions) -> bool:
        # Main installation method
        try:
            if options.update_system:
                self.logger.info("Updating system...")

                if not await self.package_manager.update_system():
                    raise Exception("System update failed")

            await self._install_system_packages()
            await self._install_aur_packages()
            await self._install_drivers(options.graphics_driver)

            if options.dotfiles:
                await self._install_dotfiles()

            return True

        except Exception as e:
            self.logger.error(f"Installation error: {e}")

            return False

    # Install system packages from pacman
    async def _install_system_packages(self) -> None:
        pacman_packages = self.config.get_packages(PackageManagerType.PACMAN)

        self.logger.info("Installing system packages...")

        results = await self.package_manager.install_packages(pacman_packages, PackageManagerType.PACMAN)

        # Get failed packages
        failed = [r.package for r in results if not r.success]
        if failed:
            raise Exception(f"Failed to install packages: {', '.join(failed)}")

    # Install packages from AUR
    async def _install_aur_packages(self) -> None:
        # Check if yay is installed
        success, _ = await SystemUtils.run_command("pacman -Q yay")
        if not success:
            await self._install_yay()

        aur_packages = self.config.get_packages(PackageManagerType.AUR)

        self.logger.info("Installing AUR packages...")

        results = await self.package_manager.install_packages(aur_packages, PackageManagerType.AUR)

        # Get failed packages
        failed = [r.package for r in results if not r.success]
        if failed:
            raise Exception(f"Failed to install packages: {', '.join(failed)}")
        
    # Install yay AUR helper
    async def _install_yay(self) -> None:
        self.logger.info("Installing yay...")
        
       # Clone yay
        if not await SystemUtils.run_command_with_wait(
            ["git", "-C", "/tmp", "clone", "https://aur.archlinux.org/yay.git"]
        ):
            raise Exception("Failed to clone yay repository")
        
        # Build and install yay
        if not await SystemUtils.run_command_with_wait(
            ["makepkg", "-si"],
            cwd="/tmp/yay"
        ):
            raise Exception("Failed to build and install yay")
        
        self.logger.success("Yay installed successfully")
        
        # Cleanup
        if not await SystemUtils.run_command(f"rm -rf /tmp/yay"):
            self.logger.warning("Failed to cleanup yay build directory")

    # Install graphics drivers
    async def _install_drivers(self, driver_type: DriverType) -> None:
        if driver_type == DriverType.NONE:
            return

        driver_packages = self.config.get_driver_packages(driver_type)

        self.logger.info(f"Installing {driver_type.value} drivers...")

        results = await self.package_manager.install_packages(driver_packages, PackageManagerType.PACMAN)

        if not all(r.success for r in results):
            raise Exception("Failed to install some packages")

    # Install dotfiles and system configuration
    async def _install_dotfiles(self) -> None:
        try:
            await self._create_default_folders()
            await self._copy_dotfiles()
        except Exception as e:
            self.logger.error(f"Dotfiles installation error: {e}")
            raise

    # Create default system folders
    async def _create_default_folders(self) -> None:
        for folder in self.config.get_default_folders():
            if not await SystemUtils.create_folder(folder):
                raise Exception(f"Failed to create folder: {folder}")

    # Copy dotfiles to their destinations
    async def _copy_dotfiles(self) -> None:
        for src, dst, type in self.config.get_all_dotfiles().items():
            src_path = Path(src)
            dst_path = SystemUtils.get_path(dst.dest)
    
            if type == DotfileType.DIR:
                if not await SystemUtils.copy_folder(src_path, dst_path):
                    raise Exception(f"Failed to copy folder: {src_path} to {dst_path}")
            else:
                if not await SystemUtils.copy_file(src_path, dst_path):
                    raise Exception(f"Failed to copy file: {src_path} to {dst_path}")
