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
            await self._prepare_multilib()

            if options.update_system:
                self.logger.info("Updating system...")

                if not await self.package_manager.update_system():
                    raise Exception("System update failed")
            
            await self._install_system_packages()

            # Check if yay is installed and get its path
            success, _ = await SystemUtils.run_command("which yay")
            if not success:
                await self._install_yay()

                # Get yay path after installation
                success, output = await SystemUtils.run_command("which yay")
                if not success:
                    raise Exception(f"Yay installation failed: {output}")

            await self._install_aur_packages()
            await self._install_drivers(options.graphics_driver)

            if options.dotfiles:
                await self._install_dotfiles()

            return True

        except Exception as e:
            self.logger.error(f"Installation error: {e}")

            return False
        
    async def _prepare_multilib(self) -> None:
        self.logger.info("Preparing multilib...")
        
        try:
            # Check if multilib section exists
            success, output = await SystemUtils.run_command_with_wait(["grep", "-q", "\\[multilib\\]", "/etc/pacman.conf"])
            
            if success:
                # Multilib section exists, uncomment it
                self.logger.info("Multilib section found, uncommenting...")
                
                # Uncomment multilib section
                success, output = await SystemUtils.run_command_with_wait([
                    "sudo", "sed", "-i", "s/^#\\[multilib\\]/[multilib]/", "/etc/pacman.conf"
                ])
                if not success:
                    raise Exception(f"Failed to uncomment multilib section: {output}")
                
                # Uncomment multilib Include line
                success, output = await SystemUtils.run_command_with_wait([
                    "sudo", "sed", "-i", "/^\\[multilib\\]$/,/^\\[/ s/^#\\(Include = \\/etc\\/pacman\\.d\\/mirrorlist\\)/\\1/", "/etc/pacman.conf"
                ])
                if not success:
                    raise Exception(f"Failed to uncomment multilib include: {output}")
                    
            else:
                # Multilib section doesn't exist, add it
                self.logger.info("Multilib section not found, adding...")
                
                success, output = await SystemUtils.run_command_with_wait([
                    "sudo", "sh", "-c", 'echo -e "\n[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf'
                ])
                if not success:
                    raise Exception(f"Failed to add multilib section: {output}")
            
            self.logger.success("Multilib repository prepared successfully")
            
        except Exception as e:
            raise Exception(f"Multilib preparation error: {e}")

    # Install system packages from pacman
    async def _install_system_packages(self) -> None:
        pacman_packages = self.config.get_packages(PackageManagerType.PACMAN)
        
        self.logger.info("Installing system packages...")

        results = await self.package_manager.install_packages(pacman_packages, PackageManagerType.PACMAN)

        # Get failed packages
        failed = [r.package for r in results if not r.success]

        self.logger.success("System packages installed successfully")
        if failed:
            raise Exception(f"Failed to install packages: {', '.join(failed)}")
        
    async def _install_yay(self) -> None:
        self.logger.info("Installing yay...")

        try:
            # Clone yay repository
            success, output = await SystemUtils.run_command_with_wait(
                ["git", "-C", "/tmp", "clone", "https://aur.archlinux.org/yay-bin.git"]
            )
            if not success:
                raise Exception(f"Failed to clone yay repository: {output}")
                
             # Build and install yay
            success, output = await SystemUtils.run_command_with_wait(
                ["bash", "-c", "cd /tmp/yay-bin && makepkg -si --noconfirm"],
                cwd="/tmp/yay-bin"
            )
            if not success:
                raise Exception(f"Failed to build and install yay: {output}")
            
            # Wait for yay to be available
            if not await SystemUtils.wait_for_package_installation("yay"):
                raise Exception("Yay installation verification failed")

            self.logger.success("Yay installed successfully")

        finally:
            # Cleanup
            success, output = await SystemUtils.run_command_with_wait(["rm", "-rf", "/tmp/yay-bin"])
            if not success:
                self.logger.warning(f"Failed to cleanup yay build directory: {output}")


    # Install packages from AUR
    async def _install_aur_packages(self) -> None:
        aur_packages = self.config.get_packages(PackageManagerType.AUR)

        self.logger.info("Installing AUR packages...")

        results = await self.package_manager.install_packages(aur_packages, PackageManagerType.AUR)

        # Get failed packages
        failed = [r.package for r in results if not r.success]

        self.logger.success("AUR packages installed successfully")
        if failed:
            raise Exception(f"Failed to install packages: {', '.join(failed)}")

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
            raise Exception(f"Dotfiles installation error: {e}")

     # Create default system folders
    async def _create_default_folders(self) -> None:
        for folder in self.config.get_default_folders():
            folder_path = SystemUtils.get_path(folder)

            if not await SystemUtils.create_folder(folder_path):
                raise Exception(f"Failed to create folder: {folder_path}")
            else:
                self.logger.success(f"Created folder: {folder_path}")

    # Copy dotfiles to their destinations
    async def _copy_dotfiles(self) -> None:
        # Get the root directory of the project
        project_root = Path.cwd()
        self.logger.info(f"Project root: {project_root}")

        for _, dotfile_config in self.config.get_all_dotfiles().items():
            src_path = project_root / dotfile_config.source
            dst_path = SystemUtils.get_path(dotfile_config.dest)
    
            if dotfile_config.type == DotfileType.DIR:
                if not await SystemUtils.copy_folder(src_path, dst_path):
                    raise Exception(f"Failed to copy folder: {src_path} to {dst_path}")
                else:
                    self.logger.success(f"Copied folder: {src_path} → {dst_path}")
            else:
                if not await SystemUtils.copy_file(src_path, dst_path):
                    raise Exception(f"Failed to copy file: {src_path} to {dst_path}")
                else:
                    self.logger.success(f"Copied file: {src_path} → {dst_path}")
