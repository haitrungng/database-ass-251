import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

export function transformFormField(field: string): string {
  let result;
  switch (field) {
    case 'Ho':
      result = 'Họ';
      break;
    case 'Dem':
      result = ' Tên Đệm';
      break;
    case 'Ten':
      result = 'Tên';
      break;
    case 'NgaySinh':
      result = 'Ngày sinh';
      break;
    case 'GioiTinh':
      result = 'Giới tính';
      break;
    case 'SoDienThoai':
      result = 'Số điện thoại';
      break;
    case 'BenhVien_ID':
      result = 'Mã Bệnh viện';
      break;
    case 'Khoa_ID':
      result = 'Mã Khoa';
      break;
    default:
      result = field;
  }
  return result;
}
