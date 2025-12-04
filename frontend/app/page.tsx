import Link from 'next/link';
import Image from 'next/image';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import {
  Table,
  TableHeader,
  TableHead,
  TableRow,
  TableBody,
  TableCell,
} from '@/components/ui/table';

type StatCard = {
  title: string;
  value: string;
  subtitle: string;
};

type QuickLink = {
  label: string;
  href: string;
  description: string;
};

type Appointment = {
  time: string;
  patient: string;
  doctor: string;
  room: string;
};

const stats: StatCard[] = [
  {
    title: 'Bệnh nhân đang điều trị',
    value: '124',
    subtitle: 'Cập nhật trong ngày',
  },
  {
    title: 'Bác sĩ đang làm việc',
    value: '38',
    subtitle: 'Đủ chuyên khoa',
  },
  {
    title: 'Cuộc hẹn hôm nay',
    value: '56',
    subtitle: 'Bao gồm khám & xét nghiệm',
  },
  {
    title: 'Tỉ lệ hài lòng',
    value: '97%',
    subtitle: 'Khảo sát 3 tháng gần đây',
  },
];

const quickLinks: QuickLink[] = [
  {
    label: 'Quản lý nhân viên',
    href: '/nhanvien',
    description: 'Thêm, sửa, xóa nhân viên & phân khoa.',
  },
  {
    label: 'Lịch hẹn bác sĩ',
    href: '/bacsi/BS00001/cuochen',
    description: 'Xem lịch hẹn theo từng bác sĩ.',
  },
  {
    label: 'Thống kê dịch vụ',
    href: '/thongke/dichvu-benhnhan',
    description: 'Xem số lần sử dụng dịch vụ theo bệnh nhân.',
  },
];

const todayAppointments: Appointment[] = [
  {
    time: '08:00',
    patient: 'Nguyễn Văn An',
    doctor: 'BS. BS00001',
    room: 'P.101',
  },
  {
    time: '09:15',
    patient: 'Trần Thị Bích',
    doctor: 'BS. BS00002',
    room: 'P.201',
  },
  {
    time: '10:30',
    patient: 'Lê Hoàng Cường',
    doctor: 'BS. BS00003',
    room: 'P.301',
  },
  {
    time: '14:00',
    patient: 'Phạm Minh Dung',
    doctor: 'BS. BS00004',
    room: 'P.401',
  },
];

export default function HospitalDashboardPage() {
  return (
    <div className='container mx-auto p-6 space-y-8'>
      {/* HERO */}
      <section className='flex flex-col lg:flex-row gap-6 lg:items-center'>
        <div className='flex-1 space-y-4'>
          <p className='text-sm uppercase tracking-[0.2em] text-muted-foreground'>
            Hệ thống quản lý bệnh viện
          </p>
          <h1 className='text-3xl md:text-4xl font-bold tracking-tight'>
            Bảng điều khiển tổng quan
          </h1>
          <p className='text-sm md:text-base text-muted-foreground max-w-xl'>
            Giám sát nhanh tình hình bệnh viện, truy cập các phân hệ quan trọng:
            nhân viên, lịch hẹn, dịch vụ & thống kê, tất cả trên một màn hình.
          </p>

          <div className='flex flex-wrap gap-3'>
            <Button asChild>
              <Link href='/nhanvien'>Quản lý nhân viên</Link>
            </Button>
            <Button variant='outline' asChild>
              <Link href='/thongke/dichvu-benhnhan'>Xem thống kê dịch vụ</Link>
            </Button>
          </div>
        </div>

        {/* HÌNH ẢNH 1 */}
        <div className='flex-1'>
          <Card className='overflow-hidden border-0 shadow-md'>
            <div className='relative aspect-[4/3]'>
              <Image
                src='https://images.unsplash.com/photo-1586773860418-d37222d8fce3?auto=format&fit=crop&w=1200&q=80'
                alt='Khu vực tiếp nhận của bệnh viện'
                fill
                className='object-cover'
                sizes='(min-width: 1024px) 400px, 100vw'
                priority
              />
            </div>
          </Card>
        </div>
      </section>

      {/* THỐNG KÊ NHANH */}
      <section className='grid gap-4 md:grid-cols-2 lg:grid-cols-4'>
        {stats.map((item) => (
          <Card key={item.title} className='shadow-sm'>
            <CardHeader className='pb-2'>
              <CardTitle className='text-sm font-medium text-muted-foreground'>
                {item.title}
              </CardTitle>
            </CardHeader>
            <CardContent>
              <p className='text-2xl font-semibold'>{item.value}</p>
              <p className='text-xs text-muted-foreground mt-1'>
                {item.subtitle}
              </p>
            </CardContent>
          </Card>
        ))}
      </section>

      {/* HÀNG DƯỚI: LỊCH HẸN & LỐI TẮT */}
      <section className='grid gap-6 lg:grid-cols-[2fr,1.4fr]'>
        {/* LỊCH HẸN HÔM NAY */}
        <Card className='shadow-sm'>
          <CardHeader>
            <CardTitle className='text-lg'>Lịch hẹn hôm nay</CardTitle>
          </CardHeader>
          <CardContent>
            <div className='w-full overflow-x-auto'>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Giờ</TableHead>
                    <TableHead>Bệnh nhân</TableHead>
                    <TableHead>Bác sĩ</TableHead>
                    <TableHead>Phòng</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {todayAppointments.map((item) => (
                    <TableRow key={`${item.time}-${item.patient}`}>
                      <TableCell className='font-medium'>{item.time}</TableCell>
                      <TableCell>{item.patient}</TableCell>
                      <TableCell>{item.doctor}</TableCell>
                      <TableCell>{item.room}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>

            <p className='mt-3 text-xs text-muted-foreground'>
              * Dữ liệu minh họa. Có thể thay bằng dữ liệu thật từ API
              <code className='mx-1 rounded bg-muted px-1 py-0.5'>
                /api/bacsi/[id]/cuochen
              </code>
              cho từng bác sĩ.
            </p>
          </CardContent>
        </Card>

        {/* LỐI TẮT + HÌNH ẢNH 2 */}
        <div className='space-y-4'>
          <Card className='shadow-sm'>
            <CardHeader>
              <CardTitle className='text-lg'>Lối tắt nhanh</CardTitle>
            </CardHeader>
            <CardContent className='space-y-3'>
              {quickLinks.map((link) => (
                <div
                  key={link.href}
                  className='flex items-start justify-between gap-2 rounded-lg border bg-muted/40 px-3 py-2'
                >
                  <div>
                    <p className='text-sm font-medium'>{link.label}</p>
                    <p className='text-xs text-muted-foreground'>
                      {link.description}
                    </p>
                  </div>
                  <Button size='sm' variant='outline' asChild>
                    <Link href={link.href}>Mở</Link>
                  </Button>
                </div>
              ))}
            </CardContent>
          </Card>

          {/* HÌNH ẢNH 2 */}
          <Card className='shadow-sm overflow-hidden'>
            <CardHeader className='pb-2'>
              <CardTitle className='text-sm'>Hình ảnh khoa khám bệnh</CardTitle>
            </CardHeader>
            <CardContent className='pt-0'>
              <div className='relative aspect-[16/9] rounded-xl overflow-hidden'>
                <Image
                  src='https://plus.unsplash.com/premium_photo-1661723555220-c7580a83f490?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
                  alt='Khu vực làm việc của đội ngũ y tế'
                  className='object-cover w-full'
                  width={1000}
                  height={500}
                />
              </div>
            </CardContent>
          </Card>
        </div>
      </section>
    </div>
  );
}
