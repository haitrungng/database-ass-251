'use client';

import { Button } from '@/components/ui/button';
import {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
  CommandSeparator,
} from '@/components/ui/command';
import { Separator } from '@/components/ui/separator';
import { bacSi, khoa } from '@/lib/mock-data';
import { useRef, useState } from 'react';

const SchedulePage = () => {
  const [khoaChosed, setKhoaChosed] = useState<string | null>(null);
  const [bacSiChosed, setBacSiChosed] = useState<string | null>(null);
  const [inputValue, setInputValue] = useState(''); // ⭐ control value
  const khoaRef = useRef<HTMLInputElement>(null);
  const bacSiRef = useRef<HTMLInputElement>(null);

  return (
    <div className='w-full p-8'>
      <Card className='w-full min-h-100'>
        <CardHeader>
          <CardTitle>Các phòng khoa</CardTitle>
          <CardDescription>
            Hãy nhập phòng khoa bạn muốn đặt lịch khám
          </CardDescription>
        </CardHeader>
        <CardContent className='flex flex-col gap-8'>
          {/* Chọn khoa */}
          <Command className='max-h-50'>
            <CommandInput
              ref={khoaRef}
              placeholder='Nhập tên khoa'
              value={inputValue}
              onValueChange={(value) => {
                setInputValue(value);
              }}
              onFocus={() => {
                setKhoaChosed(null);
              }}
            />
            <CommandList>
              {!khoaChosed && (
                <>
                  <CommandEmpty>No results found.</CommandEmpty>
                  <CommandGroup heading='Suggestions'>
                    {khoa.map((dept) => (
                      <CommandItem
                        key={dept.id}
                        onSelect={() => {
                          setKhoaChosed(dept.name);
                          setInputValue(dept.name); // hiển thị tên khoa trong input
                          khoaRef.current?.blur(); // input không active nữa
                        }}
                      >
                        {dept.name}
                      </CommandItem>
                    ))}
                  </CommandGroup>
                </>
              )}

              <CommandSeparator />
            </CommandList>
          </Command>
          {/* Chọn bác sĩ */}
          {khoaChosed && (
            <>
              <Separator />

              <Command className='max-h-50'>
                <CardTitle className='text-center'>
                  Chọn bác sĩ cho khoa {khoaChosed}
                </CardTitle>

                <CommandInput
                  ref={bacSiRef}
                  placeholder='Nhập tên bác sĩ'
                  onValueChange={(value) => {
                    setInputValue(value);
                  }}
                  onFocus={() => {
                    // user active input lại -> mở list
                    setBacSiChosed(null);
                  }}
                />
                <CommandList>
                  {!bacSiChosed && (
                    <>
                      <CommandEmpty>No results found.</CommandEmpty>
                      <CommandGroup heading='Suggestions'>
                        {bacSi.map((doctor) => (
                          <CommandItem
                            key={doctor.id}
                            onSelect={() => {
                              setBacSiChosed(doctor.name);
                              bacSiRef.current?.blur(); // input không active nữa
                            }}
                          >
                            {doctor.name}
                          </CommandItem>
                        ))}
                      </CommandGroup>
                    </>
                  )}

                  <CommandSeparator />
                </CommandList>
              </Command>
            </>
          )}
          <Button className='mt-4' disabled={!khoaChosed}>
            {' '}
            Đặt lịch khám{' '}
            {khoaChosed && bacSiChosed
              ? `với ${bacSiChosed} ở ${khoaChosed}`
              : 'ngay bây giờ'}
          </Button>
        </CardContent>
      </Card>
    </div>
  );
};

export default SchedulePage;
