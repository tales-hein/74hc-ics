# ICs 74HC em Verilog

Projeto pessoal para praticar Verilog modelando ICs da família lógica 74HC. Usei IA apenas para tirar dúvidas sem pedir código, a ideia é aprender e depois quem sabe criar algo com esses módulos demonstrando/validando que funcionam.
A lista começa com portas lógicas básicas e avança para decodificadores, multiplexadores, aritmética e lógica sequencial.

Cada IC fica em sua própria pasta:

```
ic-74HCxx/
├── ic-74HCxx.v      # módulo
├── ic-74HCxx-tb.v   # testbench
└── ref.pdf          # datasheet usado como referência
```

## Rodando uma simulação

Usa [Icarus Verilog](https://steveicarus.github.io/iverilog/) e GTKWave:

```sh
cd ic-74HC00
iverilog -o sim ic-74HC00.v ic-74HC00-tb.v
vvp sim
gtkwave wave.vcd
```

`sim` e `wave.vcd` estão no `.gitignore`.

## Progresso

✅ concluído (módulo + testbench) · ⬜ planejado

### Portas lógicas básicas

| Status | IC | Descrição |
| :----: | -- | --------- |
| ✅ | 74HC00 | 4 portas NAND de 2 entradas |
| ✅ | 74HC02 | 4 portas NOR de 2 entradas |
| ✅ | 74HC04 | 6 inversores |
| ✅ | 74HC08 | 4 portas AND de 2 entradas |
| ✅ | 74HC10 | 3 portas NAND de 3 entradas |
| ✅ | 74HC20 | 2 portas NAND de 4 entradas |
| ✅ | 74HC27 | 3 portas NOR de 3 entradas |
| ✅ | 74HC32 | 4 portas OR de 2 entradas |
| ✅ | 74HC86 | 4 portas XOR de 2 entradas |

### Decodificadores e multiplexadores

| Status | IC | Descrição |
| :----: | -- | --------- |
| ✅ | 74HC138 | Decodificador/demultiplexador 3 para 8 |
| ✅ | 74HC139 | 2 decodificadores/demultiplexadores 2 para 4 |
| ✅ | 74HC151 | Multiplexador de 8 entradas |
| ✅ | 74HC153 | 2 multiplexadores de 4 entradas |
| ✅ | 74HC157 | 4 multiplexadores de 2 entradas |
| ✅ | 74HC251 | Multiplexador de 8 entradas, 3-state |
| ✅ | 74HC258 | 4 multiplexadores de 2 entradas, invertido, 3-state |

### Buffers e transceptores (3-state)

| Status | IC | Descrição |
| :----: | -- | --------- |
| ✅ | 74HC125 | 4 buffers/drivers de linha, 3-state |
| ✅ | 74HC245 | Transceptor de barramento de 8 bits, 3-state |
| ✅ | 74HC541 | Buffer/driver de linha de 8 bits, 3-state |

### Aritmética e comparadores

| Status | IC | Descrição |
| :----: | -- | --------- |
| ⬜ | 74HC85 | Comparador de magnitude de 4 bits |
| ⬜ | 74HC283 | Somador completo binário de 4 bits |
| ⬜ | 74HC688 | Comparador de identidade de 8 bits |

### Flip-flops e latches

| Status | IC | Descrição |
| :----: | -- | --------- |
| ⬜ | 74HC74 | 2 flip-flops D com set/reset |
| ⬜ | 74HC273 | 8 flip-flops D com reset |
| ⬜ | 74HC373 | 8 latches D, 3-state |
| ⬜ | 74HC377 | 8 flip-flops D com enable |
| ⬜ | 74HC574 | 8 flip-flops D, 3-state |

### Contadores

| Status | IC | Descrição |
| :----: | -- | --------- |
| ⬜ | 74HC161 | Contador binário síncrono de 4 bits, reset assíncrono |
| ⬜ | 74HC163 | Contador binário síncrono de 4 bits, reset síncrono |
| ⬜ | 74HC393 | 2 contadores binários ripple de 4 bits |
| ⬜ | 74HC590 | Contador binário de 8 bits com registrador de saída, 3-state |
| ⬜ | 74HC4017 | Contador de década Johnson com 10 saídas decodificadas |
| ⬜ | 74HC4040 | Contador binário ripple de 12 estágios |

### Registradores de deslocamento

| Status | IC | Descrição |
| :----: | -- | --------- |
| ⬜ | 74HC165 | Registrador de deslocamento de 8 bits, entrada paralela/saída serial |
| ⬜ | 74HC194 | Registrador de deslocamento universal bidirecional de 4 bits |
| ⬜ | 74HC299 | Registrador universal de deslocamento/armazenamento de 8 bits, 3-state |

**Total: 11 / 38 concluídos**
