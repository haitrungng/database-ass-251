'use client';

import { useEffect, useState } from 'react';
import { z } from 'zod';
import { useForm, SubmitHandler } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';

import {
  Form,
  FormField,
  FormItem,
  FormLabel,
  FormControl,
  FormMessage,
} from '@/components/ui/form';

import { Input } from '@/components/ui/input';
import { Button } from '@/components/ui/button';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';

import {
  Dialog,
  DialogTrigger,
  DialogContent,
  DialogHeader,
  DialogFooter,
  DialogTitle,
} from '@/components/ui/dialog';

import {
  Table,
  TableHeader,
  TableRow,
  TableHead,
  TableBody,
  TableCell,
} from '@/components/ui/table';

// -----------------------------
// ZOD SCHEMA
// -----------------------------
const NhanVienSchema = z.object({
  ID: z.string().min(1, { message: 'ID không được để trống' }),
  CCCD: z.string().min(9, { message: 'CCCD phải >= 9 ký tự' }),
  Ho: z.string().min(1),
  Dem: z.string().optional(),
  Ten: z.string().min(1),
  NgaySinh: z.string().min(1),
  GioiTinh: z.enum(['Nam', 'Nữ']),
  SoDienThoai: z.string().min(8, { message: 'SĐT không hợp lệ' }),
  BenhVien_ID: z.string().min(1),
  Khoa_ID: z.string().min(1),
});

type NhanVienType = z.infer<typeof NhanVienSchema>;

export default function NhanVienPage() {
  const [data, setData] = useState<NhanVienType[]>([]);
  const [loading, setLoading] = useState(false);
  const [editData, setEditData] = useState<NhanVienType | null>(null);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  // -----------------------------
  // FORM KHỞI TẠO
  // -----------------------------
  const form = useForm<NhanVienType>({
    resolver: zodResolver(NhanVienSchema),
    defaultValues: {
      ID: '',
      CCCD: '',
      Ho: '',
      Dem: '',
      Ten: '',
      NgaySinh: '',
      GioiTinh: 'Nam',
      SoDienThoai: '',
      BenhVien_ID: '',
      Khoa_ID: '',
    },
  });

  // -----------------------------
  // LOAD LIST
  // -----------------------------
  const loadData = async () => {
    setLoading(true);
    const res = await fetch('/api/nhanvien');
    const json = await res.json();

    if (!json.success) {
      setErrorMsg(json.message);
    } else {
      setData(json.data);
    }
    setLoading(false);
  };

  useEffect(() => {
    loadData();
  }, []);

  // -----------------------------
  // SUBMIT (CREATE)
  // -----------------------------
  const onSubmit: SubmitHandler<NhanVienType> = async (values) => {
    setErrorMsg(null);

    const res = await fetch('/api/nhanvien', {
      method: 'POST',
      body: JSON.stringify(values),
    });
    const json = await res.json();

    if (!json.success) {
      setErrorMsg(json.message);
    } else {
      form.reset();
      loadData();
    }
  };

  // -----------------------------
  // UPDATE
  // -----------------------------
  const handleEditSubmit = async () => {
    if (!editData) return;

    const res = await fetch('/api/nhanvien', {
      method: 'PUT',
      body: JSON.stringify(editData),
    });

    const json = await res.json();
    if (!json.success) {
      setErrorMsg(json.message);
    } else {
      setEditData(null);
      loadData();
    }
  };

  // -----------------------------
  // DELETE
  // -----------------------------
  const handleDelete = async (id: string) => {
    if (!confirm('Bạn chắc chắn muốn xóa?')) return;

    const res = await fetch(`/api/nhanvien?id=${id}`, { method: 'DELETE' });
    const json = await res.json();

    if (!json.success) {
      setErrorMsg(json.message);
    } else {
      loadData();
    }
  };

  return (
    <div className='container mx-auto p-6 space-y-6'>
      <h1 className='text-3xl font-bold tracking-tight'>Quản lý nhân viên</h1>

      {/* FORM THÊM */}
      <Card className='shadow-sm border'>
        <CardHeader>
          <CardTitle className='text-xl'>Thêm nhân viên</CardTitle>
        </CardHeader>

        <CardContent>
          {errorMsg && <p className='text-red-500 text-sm pb-2'>{errorMsg}</p>}

          <Form {...form}>
            <form
              onSubmit={form.handleSubmit(onSubmit)}
              className='grid grid-cols-1 md:grid-cols-2 gap-4'
            >
              {/* CÁC FIELD */}
              {(
                Object.keys(NhanVienSchema.shape) as Array<keyof NhanVienType>
              ).map((field) => (
                <FormField
                  key={field}
                  control={form.control}
                  name={field}
                  render={({ field: f }) => (
                    <FormItem>
                      <FormLabel>{field}</FormLabel>
                      <FormControl>
                        <Input
                          type={field === 'NgaySinh' ? 'date' : 'text'}
                          {...f}
                        />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              ))}

              <Button type='submit' className='col-span-full mt-2'>
                Thêm
              </Button>
            </form>
          </Form>
        </CardContent>
      </Card>

      {/* DANH SÁCH */}
      <Card className='shadow-sm'>
        <CardHeader>
          <CardTitle className='text-xl'>Danh sách nhân viên</CardTitle>
        </CardHeader>

        <CardContent>
          {loading ? (
            <p className='text-sm'>Đang tải...</p>
          ) : data.length === 0 ? (
            <p className='text-sm text-muted-foreground'>Không có dữ liệu</p>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>ID</TableHead>
                  <TableHead>Họ tên</TableHead>
                  <TableHead>Khoa</TableHead>
                  <TableHead>SĐT</TableHead>
                  <TableHead></TableHead>
                </TableRow>
              </TableHeader>

              <TableBody>
                {data.map((nv) => (
                  <TableRow key={nv.ID}>
                    <TableCell>{nv.ID}</TableCell>
                    <TableCell>
                      {nv.Ho} {nv.Dem} {nv.Ten}
                    </TableCell>
                    <TableCell>{nv.Khoa_ID}</TableCell>
                    <TableCell>{nv.SoDienThoai}</TableCell>
                    <TableCell className='space-x-2'>
                      <Dialog>
                        <DialogTrigger asChild>
                          <Button
                            variant='outline'
                            size='sm'
                            onClick={() => setEditData(nv)}
                          >
                            Sửa
                          </Button>
                        </DialogTrigger>

                        <DialogContent>
                          <DialogHeader>
                            <DialogTitle>Sửa nhân viên</DialogTitle>
                          </DialogHeader>

                          {editData && (
                            <div className='grid grid-cols-1 md:grid-cols-2 gap-4 py-4'>
                              {(
                                Object.keys(NhanVienSchema.shape) as Array<
                                  keyof NhanVienType
                                >
                              ).map((field) => (
                                <div
                                  key={field}
                                  className='flex flex-col gap-1'
                                >
                                  <label className='text-sm font-medium'>
                                    {field}
                                  </label>
                                  <Input
                                    type={
                                      field === 'NgaySinh' ? 'date' : 'text'
                                    }
                                    value={editData[field] || ''}
                                    onChange={(e) =>
                                      setEditData({
                                        ...editData,
                                        [field]: e.target.value,
                                      })
                                    }
                                  />
                                </div>
                              ))}
                            </div>
                          )}

                          <DialogFooter>
                            <Button onClick={handleEditSubmit}>Lưu</Button>
                          </DialogFooter>
                        </DialogContent>
                      </Dialog>

                      <Button
                        variant='destructive'
                        size='sm'
                        onClick={() => handleDelete(nv.ID)}
                      >
                        Xóa
                      </Button>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
