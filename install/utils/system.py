from typing import Tuple
from pathlib import Path
import shutil
import asyncio


class SystemUtils:
    # Utility class for system operations and checks

    @staticmethod
    async def run_command(cmd: str) -> Tuple[bool, str]:
        # Run system command and return success status and output
        try:
            process = await asyncio.create_subprocess_shell(
                cmd,
                stdout=asyncio.subprocess.PIPE,
                stderr=asyncio.subprocess.PIPE,
            )
            
            stdout, stderr = await process.communicate()
            
            return process.returncode == 0, stdout.decode() or stderr.decode()
        except Exception as e:
            return False, str(e)

    @staticmethod
    async def wait_for_package_installation(package: str, max_attempts: int = 10, delay: int = 2) -> bool:
        for attempt in range(max_attempts):
            # Check if package is installed via pacman
            success, _ = await SystemUtils.run_command(f"pacman -Q {package}")
            if success:
                # Verify package is in PATH
                success, _ = await SystemUtils.run_command(f"which {package}")
                if success:
                    return True
                
            await asyncio.sleep(delay)
        return False

    @staticmethod
    async def get_path(path: str) -> Path:
        return Path(path).expanduser()
    
    @staticmethod
    async def create_folder(path: str) -> bool:
        try:
            Path(path).mkdir(parents=True, exist_ok=True)

            return True
        except Exception as e:
            return False
        
    @staticmethod
    async def copy_folder(src: str, dst: str) -> bool:
        try:
            shutil.copytree(src, dst, dirs_exist_ok=True)

            return True
        except Exception as e:
            return False
        
    @staticmethod
    async def copy_file(src: str, dst: str) -> bool:
        try:
            shutil.copy2(src, dst)

            return True
        except Exception as e:
            return False
            
