소스코드 수정후

```bash
make clean
make all
make test
```

수행 시 my_result에 테스트 케이스 정답과 내 소스코드 구현체 diff가 저장됩니다.
다른 점이 없다면 (즉, 테스트케이스를 통과했다면) 따로 저장되지 않습니다.
따라서 make test 이후 my_result가 비어있으면 프로젝트를 완료하셨다고 보면 됩니다.
