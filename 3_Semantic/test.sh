#!/bin/bash

make clean
make all

# 결과를 저장할 디렉토리 설정
result_directory="./my_result"

# cminus_semantic 실행 파일 확인
cminus_executable="./cminus_semantic"
if [ ! -x "$cminus_executable" ]; then
    echo "cminus_semantic 실행 파일이 현재 디렉토리에 없거나 실행 권한이 없습니다."
    exit 1
fi

# 현재 디렉토리 및 하위 디렉토리에서의 *.cm 파일 목록 가져오기
cm_files=($(find . -type f -name "*.cm"))

# 결과를 저장할 디렉토리 생성
rm -rf "$result_directory"
mkdir -p "$result_directory"

# 각 *.cm 파일에 대해 cminus_semantic 실행 및 결과 비교하여 차이점 저장
for file in "${cm_files[@]}"; do
    # 실행 결과를 임시 파일에 저장
    temp_output=$(mktemp)
    ./"$cminus_executable" "$file" > "$temp_output"
    
    # testresult 디렉토리의 동일한 파일명의 결과 파일
    expected_output="./testresult/$(basename ${file%.*}).result"
    
    # 결과 비교 및 차이점 출력
    diff_output="$result_directory/$(basename ${file%.*}).diff"
    if diff -u "$temp_output" "$expected_output" > "$diff_output"; then
        echo "File '$file'의 실행 결과가 '$expected_output'와 일치합니다."
        rm "$diff_output"
    else
        echo "File '$file'의 실행 결과가 '$expected_output'와 일치하지 않습니다. 차이점은 '$diff_output'에 저장되었습니다."
    fi
    
    # 임시 파일 삭제
    rm "$temp_output"
done
