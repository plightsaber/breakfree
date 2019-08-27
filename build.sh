#!/bin/bash
find ./src/ -name '*.lsl' -exec cp {} ./build/ \;
find ./build/ -name '*.lsl' -exec sed -i '1,2d' {} \;
find ./build/ -name '*.lsl' -exec sed -i '$d' {} \;
find ./build/ -name '*.lsl' -exec sed -i '$d' {} \;
