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
