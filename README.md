# Pyaravis

Pyaravis is a project aimed at automating the generation and publishing of Python bindings for the **[Aravis Library](https://github.com/AravisProject/aravis)**, a powerful tool for working with GenICam-compatible cameras. This repository provides a streamlined solution using Docker to handle dependencies and build the Aravis library, along with Python stubs for improved type checking.

## Example
After installing the library, you can use it as follows:
```python
from pyaravis import Aravis

# Get camera
camera = Aravis.Camera.new()
payload = camera.get_payload()
stream = camera.create_stream(None, None)

# Allocate Buffers
for i in range(0, 10):
    stream.push_buffer(Aravis.Buffer.new_allocate(payload))

# Start acquisition
camera.start_acquisition()

for i in range(0, 20):
    image = stream.pop_buffer()
    print(image)
    if image:
        stream.push_buffer(image)

# Stop acquisition
camera.stop_acquisition()
```

## Building the Library from Source
Running the Docker Compose configuration will generate all the necessary files in the `pyaravis/` directory, enabling seamless and Pythonic usage of the library:
```bash
docker compose up
```

## Packaging
After [building the library from source](#building-the-library-from-source), you can package the files for distribution:
1. Install the required dependencies:
    ```bash
    uv sync
    ```

2. Activate the virtual environment:
    ```bash
    source .venv/bin/active
    ```

3. Build the package for distribution:
    ```bash
    hatchling build
    ```

This will create distribution packages under the `dist/` folder

## License

This project uses the following libraries, both licensed under the **LGPL-2.1**:
- **[Aravis Library](https://github.com/AravisProject/aravis)**: The core library for GenICam-compatible camera control.
- **[pygobject-stubs](https://github.com/pygobject/pygobject-stubs)**: Provides type stubs for PyGObject.

Please ensure compliance with the LGPL-2.1 license when using or distributing this project.


## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
