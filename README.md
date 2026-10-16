# Double DQN on TurtleBot 2 (ROS) - Dockerized

This project contains the Dockerized environment to run the "Double DQN on TurtleBot 2(ROS)" tutorial as requested by your professor.

## Prerequisites for Windows
Since the simulation requires Gazebo (a 3D GUI application), you need an X server running on Windows to display it:
1. Install and run **VcXsrv** (or Xming) on Windows.
2. When starting VcXsrv (XLaunch), make sure to check **"Disable access control"** so Docker can connect to it.

## Build and Run

1. Open PowerShell or Command Prompt in this folder.
2. Build the Docker image:
   ```powershell
   docker-compose build
   ```
3. Run the container and start the training:
   ```powershell
   # Set the DISPLAY variable for Windows (VcXsrv)
   $env:DISPLAY="host.docker.internal:0"
   
   # Start the simulation and training
   docker-compose up
   ```

## What this Dockerfile does:
1. Uses `osrf/ros:melodic-desktop-full` as the base image.
2. Installs system dependencies to compile TurtleBot 2 packages.
3. Installs Miniconda and creates an environment `env1` with Python 3.6.
4. Installs all required python packages from `requirements.txt`.
5. Sets up the `simulation_ws` workspace, clones `openai_ros`, and the TurtleBot 2 source packages.
6. Sets up the `catkin_ws` workspace, creates `fa_turtlebot` package.
7. Clones the specific DoubleDQN code from the tutorial, places the `.world`, `.launch`, and `.yaml` files exactly where the tutorial indicates.
8. Uses an `entrypoint.sh` to properly source the environments and variables before executing.
