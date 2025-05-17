from pathlib import Path
import asyncio
import sys

from core import (Config, SystemInstaller, PackageManager, setup_logger)
from ui import CLI

async def main():
    try:
        # Setup paths
        config_dir = Path(__file__).parent / "config"
        if not config_dir.exists():
            print("Error: config directory not found")
            sys.exit(1)

        # Setup logging
        logger = setup_logger()

        # Initialize components
        config = Config(config_dir)
        package_manager = PackageManager(logger)
        installer = SystemInstaller(config, package_manager, logger)
        cli = CLI(config)

        # Get installation options
        options = await cli.get_install_options()
        
        # Run installation
        success = await installer.install(options)
        
        if success:
            logger.success("Installation completed successfully!")
        else:
            logger.error("Installation failed!")
            sys.exit(1)

    except Exception as e:
        print(f"Fatal error: {e}")
        sys.exit(1)

if __name__ == "__main__":
    asyncio.run(main())