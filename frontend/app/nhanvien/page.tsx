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
import Link from 'next/link';
import { transformFormField } from '@/lib/utils';

// -----------------------------
// ZOD SCHEMA - CREATE
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
  Khoa_ID: z.string().min(1, { message: 'Khoa_ID không được để trống' }),
});

type NhanVienType = z.infer<typeof NhanVienSchema>;

type NhanVienOutput = {
  ID: string;
  CCCD: string;
  Ho: string;
  Dem?: string;
  Ten: string;
  NgaySinh: string;
  GioiTinh: 'Nam' | 'Nữ';
  SoDienThoai: string;
  BenhVien_ID: number; // <- số, đúng với backend
  Khoa_ID: number; // <- số, đúng với backend
  TenKhoa: string;
};

// -----------------------------
// ZOD SCHEMA - EDIT (UPDATE)
// -----------------------------
const EditNhanVienSchema = z.object({
  ID: z.string(),
  SoDienThoai: z.string().length(10, { message: 'SĐT không hợp lệ' }),
  BenhVien_ID: z
    .string()
    .min(1, { message: 'BenhVien_ID không được để trống' }),
  Khoa_ID: z.string().min(1, { message: 'Khoa_ID không được để trống' }),
});

type EditNhanVienType = z.infer<typeof EditNhanVienSchema>;

type ApiResponse<T> = {
  success: boolean;
  data?: T[];
  message?: string;
};

export default function NhanVienPage() {
  const [data, setData] = useState<NhanVienOutput[]>([]);
  const [loading, setLoading] = useState<boolean>(false);

  const [createError, setCreateError] = useState<string | null>(null);
  const [editError, setEditError] = useState<string | null>(null);

  const [selectedNhanVien, setSelectedNhanVien] =
    useState<NhanVienOutput | null>(null);

  // -----------------------------
  // FORM THÊM
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
  // FORM SỬA (chỉ 4 field)
  // -----------------------------
  const editForm = useForm<EditNhanVienType>({
    resolver: zodResolver(EditNhanVienSchema),
    defaultValues: {
      ID: '',
      SoDienThoai: '',
      BenhVien_ID: '',
      Khoa_ID: '',
    },
  });

  // -----------------------------
  // LOAD LIST
  // -----------------------------
  const loadData = async (): Promise<void> => {
    setLoading(true);
    setCreateError(null);
    setEditError(null);

    try {
      const res = await fetch('/api/nhanvien');
      const json = (await res.json()) as ApiResponse<NhanVienOutput>;

      if (!json.success || !json.data) {
        setCreateError(json.message ?? 'Không tải được danh sách nhân viên');
        setData([]);
      } else {
        setData(json.data);
      }
    } catch (err) {
      const e = err as Error;
      setCreateError(e.message);
      setData([]);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    void loadData();
  }, []);

  // -----------------------------
  // SUBMIT (CREATE)
  // -----------------------------
  const onSubmit: SubmitHandler<NhanVienType> = async (values) => {
    setCreateError(null);

    try {
      const res = await fetch('/api/nhanvien', {
        method: 'POST',
        body: JSON.stringify(values),
      });
      const json = (await res.json()) as ApiResponse<never>;

      if (!json.success) {
        setCreateError(json.message ?? 'Thêm nhân viên thất bại');
      } else {
        form.reset();
        void loadData();
      }
    } catch (err) {
      const e = err as Error;
      setCreateError(e.message);
    }
  };

  // -----------------------------
  // SUBMIT (EDIT)
  // -----------------------------
  const onEditSubmit: SubmitHandler<EditNhanVienType> = async (values) => {
    setEditError(null);

    try {
      const res = await fetch('/api/nhanvien', {
        method: 'PUT',
        body: JSON.stringify(values),
      });
      const json = (await res.json()) as ApiResponse<never>;

      if (!json.success) {
        setEditError(json.message ?? 'Cập nhật thất bại');
      } else {
        setSelectedNhanVien(null);
        void loadData();
      }
    } catch (err) {
      const e = err as Error;
      setEditError(e.message);
    }
  };

  // -----------------------------
  // DELETE
  // -----------------------------
  const handleDelete = async (id: string): Promise<void> => {
    if (!window.confirm('Bạn chắc chắn muốn xóa?')) return;

    setCreateError(null);
    setEditError(null);

    try {
      const res = await fetch(`/api/nhanvien?id=${encodeURIComponent(id)}`, {
        method: 'DELETE',
      });
      const json = (await res.json()) as ApiResponse<never>;

      if (!json.success) {
        setCreateError(json.message ?? 'Xóa nhân viên thất bại');
      } else {
        void loadData();
      }
    } catch (err) {
      const e = err as Error;
      setCreateError(e.message);
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
          {createError && (
            <p className='text-red-500 text-sm pb-2'>{createError}</p>
          )}

          <Form {...form}>
            <form
              onSubmit={form.handleSubmit(onSubmit)}
              className='grid grid-cols-1 md:grid-cols-2 gap-4'
            >
              {(
                Object.keys(NhanVienSchema.shape) as Array<keyof NhanVienType>
              ).map((field) => (
                <FormField
                  key={field}
                  control={form.control}
                  name={field}
                  render={({ field: f }) => (
                    <FormItem>
                      <FormLabel>{transformFormField(field)}</FormLabel>
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
                    <TableCell>{nv.TenKhoa}</TableCell>
                    <TableCell>{nv.SoDienThoai}</TableCell>
                    <TableCell className='space-x-2'>
                      <Dialog
                        open={selectedNhanVien?.ID === nv.ID}
                        onOpenChange={(open) => {
                          if (open) {
                            setSelectedNhanVien(nv);
                            editForm.reset({
                              ID: nv.ID,
                              SoDienThoai: nv.SoDienThoai,
                              BenhVien_ID: String(nv.BenhVien_ID),
                              Khoa_ID: String(nv.Khoa_ID),
                            });
                            setEditError(null);
                          } else {
                            setSelectedNhanVien(null);
                            setEditError(null);
                          }
                        }}
                      >
                        <DialogTrigger asChild>
                          <Button variant='outline' size='sm'>
                            Sửa
                          </Button>
                        </DialogTrigger>

                        <DialogContent>
                          <DialogHeader>
                            <DialogTitle>Sửa nhân viên</DialogTitle>
                          </DialogHeader>

                          {selectedNhanVien && (
                            <div className='space-y-4'>
                              {/* THÔNG TIN CƠ BẢN (READONLY) */}
                              <div className='grid grid-cols-1 md:grid-cols-2 gap-3'>
                                <div>
                                  <div className='text-xs text-muted-foreground'>
                                    ID
                                  </div>
                                  <Input value={selectedNhanVien.ID} disabled />
                                </div>
                                <div>
                                  <div className='text-xs text-muted-foreground'>
                                    CCCD
                                  </div>
                                  <Input
                                    value={selectedNhanVien.CCCD}
                                    disabled
                                  />
                                </div>
                                <div>
                                  <div className='text-xs text-muted-foreground'>
                                    Họ tên
                                  </div>
                                  <Input
                                    value={`${selectedNhanVien.Ho} ${
                                      selectedNhanVien.Dem ?? ''
                                    } ${selectedNhanVien.Ten}`}
                                    disabled
                                  />
                                </div>
                                <div>
                                  <div className='text-xs text-muted-foreground'>
                                    Ngày sinh
                                  </div>
                                  <Input
                                    value={selectedNhanVien.NgaySinh}
                                    disabled
                                  />
                                </div>
                                <div>
                                  <div className='text-xs text-muted-foreground'>
                                    Giới tính
                                  </div>
                                  <Input
                                    value={selectedNhanVien.GioiTinh}
                                    disabled
                                  />
                                </div>
                                <div>
                                  <div className='text-xs text-muted-foreground'>
                                    Khoa hiện tại
                                  </div>
                                  <Input
                                    value={selectedNhanVien.TenKhoa}
                                    disabled
                                  />
                                </div>
                              </div>

                              {/* FORM EDIT 3 FIELD */}
                              {editError && (
                                <p className='text-sm text-red-500'>
                                  {editError}
                                </p>
                              )}

                              <Form {...editForm}>
                                <form
                                  onSubmit={editForm.handleSubmit(onEditSubmit)}
                                  className='grid grid-cols-1 md:grid-cols-2 gap-3'
                                >
                                  <FormField
                                    control={editForm.control}
                                    name='SoDienThoai'
                                    render={({ field }) => (
                                      <FormItem>
                                        <FormLabel>Số điện thoại</FormLabel>
                                        <FormControl>
                                          <Input {...field} />
                                        </FormControl>
                                        <FormMessage />
                                      </FormItem>
                                    )}
                                  />

                                  <FormField
                                    control={editForm.control}
                                    name='BenhVien_ID'
                                    render={({ field }) => (
                                      <FormItem>
                                        <FormLabel>BenhVien_ID</FormLabel>
                                        <FormControl>
                                          <Input {...field} />
                                        </FormControl>
                                        <FormMessage />
                                      </FormItem>
                                    )}
                                  />

                                  <FormField
                                    control={editForm.control}
                                    name='Khoa_ID'
                                    render={({ field }) => (
                                      <FormItem>
                                        <FormLabel>Khoa_ID</FormLabel>
                                        <FormControl>
                                          <Input {...field} />
                                        </FormControl>
                                        <FormMessage />
                                      </FormItem>
                                    )}
                                  />

                                  {/* Ẩn ID nhưng vẫn submit */}
                                  <input
                                    type='hidden'
                                    {...editForm.register('ID')}
                                  />

                                  <DialogFooter className='col-span-full'>
                                    <Button type='submit'>Lưu</Button>
                                  </DialogFooter>
                                </form>
                              </Form>
                            </div>
                          )}
                        </DialogContent>
                      </Dialog>

                      <Button
                        variant='destructive'
                        size='sm'
                        onClick={() => void handleDelete(nv.ID)}
                      >
                        Xóa
                      </Button>

                      {nv.ID.includes('BS') && (
                        <Button variant='secondary' size='sm'>
                          <Link href={`/bacsi/${nv.ID}/cuochen`}>
                            Xem lịch hẹn
                          </Link>
                        </Button>
                      )}
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
