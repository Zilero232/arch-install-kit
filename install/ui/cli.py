from dataclasses import dataclass
import asyncio
import os

from core import Config, DriverType

@dataclass
class InstallOptions:
    dotfiles: bool
    update_system: bool
    graphics_driver: DriverType

class CLI:
    def __init__(self, config: Config):
        self.config = config
        self.ci_mode = os.getenv("CI_MODE", "false").lower() == "true"

    async def get_install_options(self) -> InstallOptions:
        print("\n=== Arch Linux Installation ===\n")
        
        dotfiles = await self._get_boolean_option(
            "Install dotfiles and system configuration?"
        )
        
        update_system = await self._get_boolean_option(
            "Update Arch Linux database and packages?"
        )

        driver = await self._get_driver_option()

        return InstallOptions(
            dotfiles=dotfiles,
            update_system=update_system,
            graphics_driver=driver
        )

    async def _get_boolean_option(self, prompt: str) -> bool:
        if self.ci_mode:
            return os.getenv('CI_INSTALL_ALL') == 'true'            

        loop = asyncio.get_event_loop()

        while True:
            response = await loop.run_in_executor(
                None,
                lambda: input(f"{prompt} [Y/n]: ").strip().lower()
            )
            
            if response in ["", "y", "yes"]:
                return True
            elif response in ["n", "no"]:
                return False
            print("Please answer 'y' or 'n'")
        
    async def _get_driver_option(self) -> DriverType:
        if self.ci_mode:
            driver = os.getenv('CI_DRIVER', 'none').upper()

            return DriverType[driver]

        print("\nSelect graphics driver:")
        print("1) NVIDIA")
        print("2) Intel")
        print("3) AMD Radeon")
        print("4) Skip driver installation")
        
        loop = asyncio.get_event_loop()

        while True:
            choice = await loop.run_in_executor(
                None,
                lambda: input("Выбор [1-4]: ").strip()
            )
            
            if choice == "1":
                return DriverType.NVIDIA
            elif choice == "2":
                return DriverType.INTEL
            elif choice == "3":
                return DriverType.RADEON
            elif choice == "4":
                return DriverType.NONE
            print("Please select 1-4")