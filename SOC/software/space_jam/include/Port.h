#ifndef SPI_SS_H
#define SPI_SS_H
#include "stdint.h"

typedef uint8_t DataT;

class SPI_SS{
	public:
	typedef uint8_t DataT;
	public:
	static void Write(DataT value);
	static void ClearAndSet(DataT clearMask, DataT value);
	static DataT Read();
	static void DirWrite(DataT value);
	static DataT DirRead();
	static void Set(DataT value);
	static void Set();
	static void Clear(DataT value);
	static void Clear();
	static void Toggle(DataT value);
	static void DirSet(DataT value);
	static void DirClear(DataT value);
	static void DirToggle(DataT value);
	static void SetDirWrite();
	static DataT PinRead();
	enum{Id = 0};
	enum{Width=sizeof(DataT)*8};
};
#endif

#ifndef INTR_H
#define INTR_H
class INTR{
	public:
	typedef uint8_t DataT;
	public:
	static void Write(DataT value);
	static void ClearAndSet(DataT clearMask, DataT value);
	static DataT Read();
	static void DirWrite(DataT value);
	static DataT DirRead();
	static void Set(DataT value);
	static void Set();
	static void Clear(DataT value);
	static void Clear();
	static void Toggle(DataT value);
	static void DirSet(DataT value);
	static void DirClear(DataT value);
	static void DirToggle(DataT value);
	static void SetDirWrite();
	static void SetDirRead();
	static int IsSet();
	static DataT PinRead();
	enum{Id = 0};
	enum{Width=sizeof(DataT)*8};
};
#endif
