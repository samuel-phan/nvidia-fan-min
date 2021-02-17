# NVIDIA fan minimum speed

This small project is to have a systemd service to set the NVIDIA fan at a minimum speed.

# What does it do?

When GPU temperature is:

- < 40°C: the fan is set to 20% of speed.
- \>= 40°C: then fan control is given to the NVIDIA driver.

# Disclaimer

No warranty about this tool, use at your own risk.

# How to install

Edit the `nvidia-fan-min.service` file to set the `ExecStart` value to the location of your script `nvidia-fan-min.sh`.

```
sudo ln -s /path/to/nvidia-fan-min.service /etc/systemd/system/nvidia-fan-min.service
sudo systemctl enable nvidia-fan-min
sudo systemctl start nvidia-fan-min
```

You can check logs in `/var/log/syslog` when the GPU fan control is changed.

# Story

My NVIDIA GeForce 2060 SUPER stops the fan when the GPU is not used too much.

On Linux Mint 20, there is a very annoying behavior though: the fan starts to spin very loudly for a brief moment (~2s)
to reach 2000 RPM, but in the end, it disturbs me and makes more noise than the silence that was aimed in the first
place.

I prefer to have my graphic card fan spinning at low speed all the time than this variable fan control.