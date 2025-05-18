from typing import Tuple
from .system import SystemUtils

class UserUtils:
		BUILD_USER = "builder"

    @staticmethod
    async def is_root() -> bool:
        success, output = await SystemUtils.run_command("id -u")

        return success and output.strip() == "0"

    @staticmethod
    async def create_build_user(username: str = "builder") -> Tuple[bool, str]:
       	cmd = f"useradd -m -G wheel {UserUtils.BUILD_USER}"
        success, output = await SystemUtils.run_command(cmd)
        if not success:
            return False, f"Failed to create user: {output}"
            
        # Set passwordless sudo for makepkg
        cmd = f"echo '{UserUtils.BUILD_USER} ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/builder"
        success, output = await SystemUtils.run_command(cmd)
        if not success:
            return False, f"Failed to set sudo rights: {output}"
            
        return True, UserUtils.BUILD_USER

    @staticmethod
    async def remove_build_user(username: str = "builder") -> Tuple[bool, str]:
        cmd = f"userdel -r {username}"

        return await SystemUtils.run_command(cmd)

    @staticmethod
    async def get_current_user() -> Tuple[bool, str]:
        return await SystemUtils.run_command("whoami")