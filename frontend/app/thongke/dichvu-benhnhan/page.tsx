'use client';

import { useEffect, useState } from 'react';
import { z } from 'zod';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import {
  Form,
  FormField,
  FormItem,
  FormLabel,
  FormControl,
  FormMessage,
} from '@/components/ui/form';
import {
  Table,
  TableHeader,
  TableHead,
  TableRow,
  TableBody,
  TableCell,
} from '@/components/ui/table';

type ServiceUsage = {
  ID: string;
  HoTen: string;
  SoLanSuDung: number;
};

type ApiResponse<T> = {
  success: boolean;
  data: T[];
  message?: string;
};

const FilterSchema = z.object({
  min: z.coerce
    .number()
    .int()
    .min(1, { message: 'Số lần tối thiểu phải >= 1' }),
});

type FilterValues = z.infer<typeof FilterSchema>;

export default function ThongKeDichVuBenhNhanPage() {
  const [rows, setRows] = useState<ServiceUsage[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const form = useForm<FilterValues>({
    resolver: zodResolver(FilterSchema),
    defaultValues: {
      min: 1,
    },
  });

  const loadData = async (min: number): Promise<void> => {
    setLoading(true);
    setError(null);

    try {
      const res = await fetch(
        `/api/thongke/dichvu-benhnhan?min=${encodeURIComponent(String(min))}`
      );
      const json = (await res.json()) as ApiResponse<ServiceUsage>;

      if (!json.success) {
        setError(json.message ?? 'Không thể tải dữ liệu thống kê');
        setRows([]);
        return;
      }

      setRows(json.data);
    } catch (err) {
      const e = err as Error;
      setError(e.message);
      setRows([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void loadData(form.getValues('min'));
  }, []);

  const onSubmit = (values: FilterValues): void => {
    void loadData(values.min);
  };

  return (
    <div className='container mx-auto p-6 space-y-6'>
      <h1 className='text-3xl font-bold tracking-tight'>
        Thống kê dịch vụ theo bệnh nhân
      </h1>

      <Card className='shadow-sm'>
        <CardHeader>
          <CardTitle className='text-lg'>Điều kiện lọc</CardTitle>
        </CardHeader>
        <CardContent>
          <Form {...form}>
            <form
              onSubmit={form.handleSubmit(onSubmit)}
              className='flex flex-col md:flex-row gap-4 md:items-end'
            >
              <FormField
                control={form.control}
                name='min'
                render={({ field }) => (
                  <FormItem className='w-full md:w-64'>
                    <FormLabel>Số lần sử dụng tối thiểu</FormLabel>
                    <FormControl>
                      <Input type='number' min={1} {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <Button type='submit' className='w-full md:w-auto'>
                Lọc
              </Button>
            </form>
          </Form>
        </CardContent>
      </Card>

      <Card className='shadow-sm'>
        <CardHeader>
          <CardTitle className='text-lg'>Kết quả thống kê</CardTitle>
        </CardHeader>
        <CardContent>
          {error && <p className='mb-3 text-sm text-red-600'>{error}</p>}

          {loading ? (
            <p className='text-sm text-muted-foreground'>Đang tải dữ liệu...</p>
          ) : rows.length === 0 ? (
            <p className='text-sm text-muted-foreground'>
              Không có bệnh nhân nào thỏa điều kiện.
            </p>
          ) : (
            <div className='w-full overflow-x-auto'>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã bệnh nhân</TableHead>
                    <TableHead>Họ tên</TableHead>
                    <TableHead className='text-right'>Số lần sử dụng</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {rows.map((row) => (
                    <TableRow key={row.ID}>
                      <TableCell>{row.ID}</TableCell>
                      <TableCell>{row.HoTen}</TableCell>
                      <TableCell className='text-right'>
                        {row.SoLanSuDung}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
