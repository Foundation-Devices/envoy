Xvfb :5 -screen 0 1920x1080x24+32 -fbdir /var/tmp &
DISPLAY=:5 flutter test integration_test -d linux