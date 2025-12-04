'use client';

import { useEffect, useMemo, useState } from 'react';
import { useParams } from 'next/navigation';
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

// -----------------------------
// TYPES
// -----------------------------
type Appointment = {
  MaCuocHen: string;
  TenBenhNhan: string;
  NgayGio: string; // ISO string
  TinhTrang: string;
};

type ApiResponse<T> = {
  success: boolean;
  data: T[];
  message?: string;
};

const FilterSchema = z.object({
  keyword: z.string().optional(),
});

type FilterValues = z.infer<typeof FilterSchema>;

// -----------------------------
// COMPONENT
// -----------------------------
export default function BacSiCuocHenPage() {
  const params = useParams<{ id: string }>();
  const id: string = params.id;

  const [appointments, setAppointments] = useState<Appointment[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const form = useForm<FilterValues>({
    resolver: zodResolver(FilterSchema),
    defaultValues: {
      keyword: '',
    },
  });

  const keywordWatch: string = form.watch('keyword') ?? '';

  const filteredAppointments = useMemo<Appointment[]>(() => {
    const trimmed = keywordWatch.trim().toLowerCase();
    if (!trimmed) return appointments;
    return appointments.filter((a) =>
      a.TenBenhNhan.toLowerCase().includes(trimmed)
    );
  }, [appointments, keywordWatch]);

  const loadData = async (): Promise<void> => {
    if (!id) return;

    setLoading(true);
    setError(null);

    try {
      const res = await fetch(`/api/bacsi/${encodeURIComponent(id)}/cuochen`);

      const contentType: string = res.headers.get('content-type') ?? '';

      // Nếu không phải JSON -> đọc text thô & báo lỗi rõ ràng
      if (!contentType.includes('application/json')) {
        const text: string = await res.text();
        setError(
          `Server trả về không phải JSON (status ${
            res.status
          }). Nội dung: ${text.slice(0, 200)}`
        );
        setAppointments([]);
        return;
      }

      const json = (await res.json()) as ApiResponse<Appointment>;

      if (!json.success) {
        setError(json.message ?? 'Không thể tải danh sách cuộc hẹn');
        setAppointments([]);
        return;
      }

      setAppointments(json.data);
    } catch (err) {
      const e = err as Error;
      setError(e.message);
      setAppointments([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void loadData();
  }, [id]);

  const onSubmit = (values: FilterValues): void => {
    form.setValue('keyword', values.keyword ?? '');
  };

  if (!id) {
    return (
      <div className='container mx-auto p-6'>
        <p className='text-sm text-muted-foreground'>
          Không tìm thấy mã bác sĩ trong URL.
        </p>
      </div>
    );
  }

  return (
    <div className='container mx-auto p-6 space-y-6'>
      <div className='flex flex-col md:flex-row md:items-end md:justify-between gap-2'>
        <div>
          <h1 className='text-3xl font-bold tracking-tight'>
            Cuộc hẹn của bác sĩ
          </h1>
          <p className='text-sm text-muted-foreground mt-1'>
            Mã bác sĩ: <span className='font-semibold'>{id}</span>
          </p>
        </div>

        <Button variant='outline' size='sm' onClick={() => void loadData()}>
          Làm mới
        </Button>
      </div>

      <Card className='shadow-sm'>
        <CardHeader>
          <CardTitle className='text-lg'>Tìm kiếm</CardTitle>
        </CardHeader>
        <CardContent>
          <Form {...form}>
            <form
              onSubmit={form.handleSubmit(onSubmit)}
              className='flex flex-col md:flex-row gap-4 md:items-end'
            >
              <FormField
                control={form.control}
                name='keyword'
                render={({ field }) => (
                  <FormItem className='w-full md:w-64'>
                    <FormLabel>Tên bệnh nhân</FormLabel>
                    <FormControl>
                      <Input placeholder='Nhập tên bệnh nhân' {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />

              <Button type='submit' className='w-full md:w-auto'>
                Áp dụng
              </Button>
            </form>
          </Form>
        </CardContent>
      </Card>

      <Card className='shadow-sm'>
        <CardHeader>
          <CardTitle className='text-lg'>Danh sách cuộc hẹn</CardTitle>
        </CardHeader>
        <CardContent>
          {error && (
            <p className='mb-3 text-sm text-red-600 whitespace-pre-wrap'>
              {error}
            </p>
          )}

          {loading ? (
            <p className='text-sm text-muted-foreground'>Đang tải dữ liệu...</p>
          ) : filteredAppointments.length === 0 ? (
            <p className='text-sm text-muted-foreground'>
              Không có cuộc hẹn nào.
            </p>
          ) : (
            <div className='w-full overflow-x-auto'>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Mã cuộc hẹn</TableHead>
                    <TableHead>Tên bệnh nhân</TableHead>
                    <TableHead>Ngày giờ</TableHead>
                    <TableHead>Tình trạng</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredAppointments.map((a) => (
                    <TableRow key={a.MaCuocHen}>
                      <TableCell>{a.MaCuocHen}</TableCell>
                      <TableCell>{a.TenBenhNhan}</TableCell>
                      <TableCell>
                        {new Date(a.NgayGio).toLocaleString('vi-VN')}
                      </TableCell>
                      <TableCell>{a.TinhTrang}</TableCell>
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
