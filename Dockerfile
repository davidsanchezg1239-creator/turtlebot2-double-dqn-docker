FROM osrf/ros:melodic-desktop-full

# Avoid user interaction during apt-get
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget git curl bzip2 \
    python-pip python3-pip \
    python-catkin-tools \
    ros-melodic-joy ros-melodic-ecl-threads \
    ros-melodic-ecl-geometry ros-melodic-ecl-streams \
    ros-melodic-yocs-controllers ros-melodic-yujin-ocs \
    ros-melodic-kobuki-msgs ros-melodic-kobuki-core \
    ros-melodic-move-base ros-melodic-map-server ros-melodic-amcl ros-melodic-navigation \
    ros-melodic-openni2-camera ros-melodic-openni2-launch ros-melodic-gmapping dos2unix \
    libgl1-mesa-glx libgl1-mesa-dri mesa-utils \
    && rm -rf /var/lib/apt/lists/*

# Create Python 3.6 virtual environment (Ubuntu 18.04 uses Python 3.6 by default)
RUN apt-get update && apt-get install -y python3-venv && rm -rf /var/lib/apt/lists/*
RUN python3 -m venv /opt/venv

# Activate the virtual environment by default
ENV PATH="/opt/venv/bin:$PATH"

# Install Python requirements
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && \
    pip install -r /tmp/requirements.txt

# Set up simulation_ws
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash && \
    mkdir -p /root/simulation_ws/src && \
    cd /root/simulation_ws/src && \
    git clone https://bitbucket.org/theconstructcore/openai_ros.git && \
    cd openai_ros && git checkout version2 && \
    sed -i \"s|'/cmd_vel'|'/cmd_vel_mux/input/navi'|g\" openai_ros/src/openai_ros/robot_envs/turtlebot2_env.py && \
    cd .. && \
    git clone https://github.com/turtlebot/turtlebot.git && \
    git clone https://github.com/turtlebot/turtlebot_simulator.git && \
    git clone https://github.com/turtlebot/turtlebot_msgs.git && \
    git clone https://github.com/turtlebot/turtlebot_apps.git && \
    git clone --single-branch --branch melodic https://github.com/yujinrobot/kobuki.git && \
    git clone https://github.com/yujinrobot/kobuki_msgs.git && \
    cd /root/simulation_ws && \
    apt-get update && rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y && \
    rm -rf /var/lib/apt/lists/* && \
    catkin_make"

# Set up catkin_ws and fa_turtlebot package
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash && \
    source /root/simulation_ws/devel/setup.bash && \
    mkdir -p /root/catkin_ws/src && \
    cd /root/catkin_ws/src && \
    catkin_create_pkg fa_turtlebot std_msgs rospy roscpp && \
    cd fa_turtlebot && \
    mkdir -p src launch config && \
    cd src && \
    git clone https://github.com/prav2909/DoubleDQN_turtlebot2.git temp_repo && \
    mv temp_repo/* . && \
    rm -rf temp_repo && \
    chmod +x start_training.py && \
    mkdir -p /root/simulation_ws/src/turtlebot_simulator/turtlebot_gazebo/worlds/ && \
    mkdir -p /root/simulation_ws/src/turtlebot_simulator/turtlebot_gazebo/launch/ && \
    mv custom_world_3.world /root/simulation_ws/src/turtlebot_simulator/turtlebot_gazebo/worlds/ && \
    mv start_world_maze_loop_brick.launch /root/simulation_ws/src/turtlebot_simulator/turtlebot_gazebo/launch/ && \
    mv start_training.launch ../launch/ && \
    mv fa_turtlebot.yaml ../config/ && \
    sed -i 's|/home/praveen/simulation_ws|/root/simulation_ws|g' ../config/fa_turtlebot.yaml && \
    sed -i 's|log_level=rospy.WARN|log_level=rospy.INFO|g' start_training.py && \
    cd /root/catkin_ws && \
    catkin_make"

COPY put_robot_in_world.launch /root/simulation_ws/src/turtlebot_simulator/turtlebot_gazebo/launch/
COPY entrypoint.sh /
RUN /bin/bash -c "source /opt/ros/melodic/setup.bash && \
    source /root/simulation_ws/devel/setup.bash && \
    cd /root/simulation_ws/src && \
    git clone --single-branch --branch melodic https://github.com/yujinrobot/kobuki_desktop.git && \
    cd /root/simulation_ws && \
    apt-get update && rosdep install --from-paths src --ignore-src -r -y && \
    catkin_make"
RUN apt-get update && apt-get install -y ros-melodic-depthimage-to-laserscan && rm -rf /var/lib/apt/lists/*
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]
