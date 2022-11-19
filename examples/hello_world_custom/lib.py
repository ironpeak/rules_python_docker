import logger
import xxhash

print(f"xxhash: {xxhash.xxh64('Hello World!').hexdigest()}")

def greet_world():
    logger.info("Hello World!")