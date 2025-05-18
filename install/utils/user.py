from typing import Tuple
from .system import SystemUtils

class UserUtils:
    BUILD_USER = "builder"

    @staticmethod
    async def is_root() -> bool:
        success, output = await SystemUtils.run_command("id -u")

        return success and output.strip() == "0"

    @staticmethod
    async def create_build_user() -> Tuple[bool, str]:
        # Create build user
        success, output = await SystemUtils.run_command_with_wait([
            "useradd", "-m", "-G", "wheel", UserUtils.BUILD_USER
        ])
        if not success:
            return False, f"Failed to create user: {output}"
            
        # Set passwordless sudo for makepkg
        success, output = await SystemUtils.run_command_with_wait([
            "echo", f"'{UserUtils.BUILD_USER} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/builder"
        ])
        if not success:
            return False, f"Failed to set sudo rights: {output}"
            
        return True, UserUtils.BUILD_USER

    @staticmethod
    async def remove_build_user() -> Tuple[bool, str]:
        # Remove build user
        success, output = await SystemUtils.run_command_with_wait([
            "userdel", "-r", UserUtils.BUILD_USER
        ])
        if not success:
            return False, f"Failed to remove user: {output}"
            
        return True, UserUtils.BUILD_USER

    @staticmethod
    async def get_current_user() -> Tuple[bool, str]:
        success, output = await SystemUtils.run_command_with_wait(["whoami"])
        if not success:
            return False, f"Failed to get current user: {output}"

        return True, output.strip()