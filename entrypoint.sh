#!/bin/bash
set -e

# Source ROS and workspaces
. /opt/ros/melodic/setup.bash

if [ -f /root/simulation_ws/devel/setup.bash ]; then
    . /root/simulation_ws/devel/setup.bash
fi

if [ -f /root/catkin_ws/devel/setup.bash ]; then
    . /root/catkin_ws/devel/setup.bash
fi

# Activate python virtual environment
. /opt/venv/bin/activate

# Export Turtlebot variables
export TURTLEBOT_BASE=kobuki
export TURTLEBOT_3D_SENSOR=kinect
export TURTLEBOT_STACK=hexagons
export GAZEBO_PLUGIN_PATH=$GAZEBO_PLUGIN_PATH:/root/simulation_ws/devel/lib

exec "$@"
