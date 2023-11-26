#include "../include/Port.h"
#include <stdio.h>
typedef uint8_t DataT;
void SPI_SS::Write(DataT value) {
	printf("Port Write\n");
}
void SPI_SS::ClearAndSet(DataT clearMask, DataT value) {
	printf("Port ClearAndSet\n");
}
DataT SPI_SS::Read() {
	printf("Port Read\n");
}
void SPI_SS::DirWrite(DataT value) {
	printf("Port DirWrite\n");
}
DataT SPI_SS::DirRead() {
	printf("Port DirRead\n");
}
void SPI_SS::Set(DataT value) {
	printf("Port Set\n");
}
void SPI_SS::Clear(DataT value) {
	printf("Port Clear\n");
}
void SPI_SS::Toggle(DataT value) {
	printf("Port Toggle\n");
}
void SPI_SS::DirSet(DataT value) {
	printf("Port DirSet\n");
}
void SPI_SS::DirClear(DataT value) {
	printf("Port DirClear\n");
}
void SPI_SS::DirToggle(DataT value) {
	printf("Port DirToggle\n");
}
DataT SPI_SS::PinRead() {
	printf("Port PinRead\n");
}
