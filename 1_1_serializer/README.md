
# rolling median filter

## task
Сериализатор на вход получает «широкие» данные — длинное слово, и отправляет по одному биту на выход.

## desc


| Имя сигнала    | Напр-е | Разрядность | Комментарий                                                                                                                                                                                                                                                                           |
| -------------- | ------ | ----------- |:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| clk_i          | input  | 1           | Тактовый сигнал.                                                                                                                                                                                                                                                                      |
| srst_i         | input  | 1           | Синхронный сброс.                                                                                                                                                                                                                                                                     |
| data_i         | input  | 16          | Входные данные.                                                                                                                                                                                                                                                                       |
| data_mod_i     | input  | 4           | Число показывает сколько бит в входных данных валидно. К примеру, если там стоит 5, то валидны старшие 5 бит [15:11], и значит только эти пять бит будут «отправлены» дальше. Если 0 – то все биты валидны. Если mod в диапазоне от 1 до 2 включительно, то эта посылка игнорируется. |
| data_val_i     | input  | 1           | Сигнал, подтверждающий, что data_i и data_mod_i валидны, держится один такт.                                                                                                                                                                                                          |
| ser_data_o     | output | 1           | «Сериализованные» данные. Будем считать, что первым битом выходит самый старший бит из data_i.                                                                                                                                                                                        |
| ser_data_val_o | output | 1           | Подтверждает валидность ser_data_o.                                                                                                                                                                                                                                                   |
| busy_o         | output | 1           | Если 1, то это говорит о том,что модуль сериализации занят, и вышестоящий модуль не пошлет новые data_i данные в тот такт, когда висит busy_o.                                                                                                                                        |


### alg
У алгоритма есть слабые места:
- Лишняя переменная data_mod_i_copy (для обработки валидности бит 0, 1 и 2, ...)
- Можно использовать цикл for вместо того, чтобы писать counter (2 блока: последовательный, для сохранения состояния итератора mod_counter, и комбинационный, для вывода информации во внешнюю среду, testbench)

- Остановка происходит за счет следующих условий: либо срабатывание reset, либо валидность входного числа, либо равенство итератора с кол-вом валидных бит
- Обратная связь осуществляется через 2 переменных ser_data_val_o и busy_o (пользовался только последней, из-за чего возникли проблемы)

### test

В начале идет первичная инициализация, до момента когда rst_done станет равен 1.

Тестирование проводится за счет генерации входных чисел data_i_var (.data_i), data_i_len (data_mod_i) в цикле. Тем самым можно покрыть все возможные наборы данных.

В скрипте для ModelSim вызываются 2 собственные функции do_compile start_sim

#### bugs
1. Возникли проблемы с тестовым циклом, хотя сам serializer исправен. Из-за того что связь осуществляется через валидный бит, в тестовом цикле генерации находится ошибка. Идея в том чтобы на каждом фронте ждать пока освободится сериализатор и передавать новое число из цикла генерации, тогда ser_data_i_val(.ser_data_val_o) каждый раз обновляясь будет равен 1, а когда числа закончатся то сериализатор работать не будет (по условию).

Вот и не смог понять когда происходит запись (пробовал negedge clk_i), в симуляторе ModelSim видно как после busy_o = 0 дважды (за 2 полных цикла) происходит инкремент data_i. От этого эффекта получилось избавиться с помощью начальной иницализации и перестановки wait() перед записью новых тестовых чисел, но только для первого значения (пробовал каждый раз делать инициализацию, но не помогает)

2. Также отсутствует синхронный reset

## install

```
git clone https://github.com/t1msi/fpga_lab_1.git
cd fpga_lab_1/1_1_serializer/tb/
vsim -c -do make.tcl

```

## ref
- https://www.youtube.com/playlist?list=PLOiK7Vmp7kf-YmjuuJKvDvmJdxKs826kx
- https://github.com/stcmtk/fpga-webinar-2020
- https://github.com/johan92/fpga-for-beginners
- https://habr.com/en/articles/281525/