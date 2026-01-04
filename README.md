## 📄 Documentation
- [📘 Final Presentation PDF](doc/RV32i_MultiCycle_AMBA_APB_UART.pdf)

---

# RV32I Multicycle CPU 및 AMBA APB UART 설계

RV32I multicycle CPU 를 설계하고, UART Peripheral을 APB BUS를 통해 연동하여 PC와 통신을 구현한 프로젝트 입니다.

---

## 프로젝트 목표

 - MultiCycle 구현 : SingleCycle로 제작된 RV32I에서 5단계의 처리과정을 지니는 MultiCycle CPU로 재구성합니다.
 - AMBA ABP BUS 구현 : AMBA APB프로토콜을 학습하고 설계합니다.
 - CPU와 Peripheral 연동 : 직접 만든 UART 모듈을 APB를 통해 CPU와 연동합니다.

---

## 개발 환경

 - 하드웨어 : Basys3
 - 언어 : SystemVerilog, C
 - 개발 도구 : Vivado, Visual Studio Code

---

## 전체 구조

### RV32I MultiCycle CPU 
<img width="1039" height="864" alt="image" src="https://github.com/user-attachments/assets/f443bbeb-58d2-474c-96fe-4bbaa1bd398f" />

<img width="1697" height="551" alt="image" src="https://github.com/user-attachments/assets/8dd23733-ad2e-48d1-9e80-e8d5dffe05a0" />

기존의 한번에 이루어지던 SingleCycle의 동작을 Fetch, Decode, Execute, Memory, Writeback의 5단계 동작으로 분리하고, 각 단계 사이에 플립플롭을 추가하여 MultiCycle구조로 변경하였습니다.

### APB State Diagram
<img width="577" height="637" alt="image" src="https://github.com/user-attachments/assets/3d110be4-7a39-439a-8924-7edb5d92efff" />
<img width="541" height="409" alt="image" src="https://github.com/user-attachments/assets/1cdf39da-4f56-4b35-8ab0-b002cccbd433" />

APB BUS에 Slave로 연결되는 UART모듈을 설계하여 APB BUS를 통해 UART레지스터에 접근하여 데이터를 송수신합니다.

---

## 주요기능 및 검증

### 1. Multi-Cycle CPU 명령어 검증

 - R-Type: 레지스터 간 산술/논리 연산
 - I-Type: 레지스터와 즉시값 간 연산
 - S-Type: 메모리에 데이터 저장
 - IL-Type (Load): 메모리에서 데이터 읽기
 - U-Type: 상위 20비트 즉시값 로드
 - B/J-Type: 분기 및 점프 제어

### 2. C언어 기반 FPGA 동작 검증

 C언어로 UART 송수신 및 LED 제어 프로그램을 작성하여 검증했습니다.

 - 현재의 상태를 주기적으로 PC에 송신합니다.
 - PC에서 L혹은R을 입력받을 경우 LED의 방향이 쉬프트됩니다.
 - 동시에 현재의 쉬프트 방향을 주기적으로 PC에 전송합니다.
 - S 입력시 쉬프트를 멈추게 됩니다.

---

## 트러블슈팅 및 고찰

 1. 처음 C언어를 통해 데이터를 올린 동작을 검증해보았기에 PC와의 통신을 하는데 어려움을 겪었습니다. 하지만 이를 통해 하드웨어와 소프트웨어적인 부분을 모두 공부할 수 있었고 CPU의 동작방식에 대해서도 더 깊은 이해도롤 가질 수 있게 되었습니다.

