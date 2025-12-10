import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { pool, getConnection, MysqlError } from '@/lib/db';
import { RowDataPacket } from 'mysql2/promise';

// -----------------------------
// ZOD SCHEMA – SOURCE OF TRUTH
// -----------------------------
export const NhanVienSchema = z.object({
  ID: z.string(),
  CCCD: z.string(),
  Ho: z.string(),
  Dem: z.string().nullable().optional(),
  Ten: z.string(),
  NgaySinh: z.string(), // dạng 'YYYY-MM-DD'
  GioiTinh: z.enum(['Nam', 'Nữ']),
  SoDienThoai: z.string(),
  BenhVien_ID: z.number(),
  Khoa_ID: z.number(),
  TenKhoa: z.string(), // <- thêm tên khoa
});

export type NhanVien = z.infer<typeof NhanVienSchema>;

// Body khi INSERT (nhận từ form → số là string nên dùng coerce)
export const InsertNhanVienSchema = z.object({
  ID: z.string(),
  CCCD: z.string(),
  Ho: z.string(),
  Dem: z.string().nullable().optional(),
  Ten: z.string(),
  NgaySinh: z.string(), // input type="date" trả ra string
  GioiTinh: z.enum(['Nam', 'Nữ']),
  SoDienThoai: z.string(),
  BenhVien_ID: z.coerce.number(),
  Khoa_ID: z.coerce.number(),
});
export type InsertNhanVienInput = z.infer<typeof InsertNhanVienSchema>;

// Body khi UPDATE
export const UpdateNhanVienSchema = z.object({
  ID: z.string(),
  SoDienThoai: z.string(),
  BenhVien_ID: z.coerce.number(),
  Khoa_ID: z.coerce.number(),
});
export type UpdateNhanVienInput = z.infer<typeof UpdateNhanVienSchema>;

// Dữ liệu thô từ MySQL (JOIN với Khoa)
export interface DbNhanVien extends RowDataPacket {
  ID: string;
  CCCD: string;
  Ho: string;
  Dem: string | null;
  Ten: string;
  NgaySinh: Date; // MySQL DATE
  GioiTinh: 'Nam' | 'Nữ';
  SoDienThoai: string;
  BenhVien_ID: number;
  Khoa_ID: number;
  TenKhoa: string;
}

// -----------------------------
// HELPER: TRẢ LỖI JSON
// -----------------------------
function error(message: string, status = 400) {
  return NextResponse.json({ success: false, message }, { status });
}

// Helper format Date -> 'YYYY-MM-DD'
function formatDate(d: Date): string {
  return d.toISOString().slice(0, 10);
}

// -----------------------------
// GET: LẤY DS NHÂN VIÊN (+ TÊN KHOA)
// -----------------------------
export async function GET() {
  try {
    const [rows] = await pool.query<DbNhanVien[]>(
      `
      SELECT 
        nv.ID,
        nv.CCCD,
        nv.Ho,
        nv.Dem,
        nv.Ten,
        nv.NgaySinh,
        nv.GioiTinh,
        nv.SoDienThoai,
        nv.BenhVien_ID,
        nv.Khoa_ID,
        k.TenKhoa
      FROM NhanVien nv
      JOIN Khoa k 
        ON k.ID = nv.Khoa_ID
       AND k.BenhVien_ID = nv.BenhVien_ID
      ORDER BY nv.ID ASC;
      `
    );

    const normalized: NhanVien[] = rows.map((row) => ({
      ID: row.ID,
      CCCD: row.CCCD,
      Ho: row.Ho,
      Dem: row.Dem ?? null,
      Ten: row.Ten,
      NgaySinh: formatDate(row.NgaySinh),
      GioiTinh: row.GioiTinh,
      SoDienThoai: row.SoDienThoai,
      BenhVien_ID: row.BenhVien_ID,
      Khoa_ID: row.Khoa_ID,
      TenKhoa: row.TenKhoa,
    }));

    const parsed = z.array(NhanVienSchema).parse(normalized);

    return NextResponse.json({
      success: true,
      data: parsed,
    });
  } catch (err) {
    const e = err as MysqlError;
    return error(e.sqlMessage ?? e.message, 500);
  }
}

// -----------------------------
// POST: THÊM NHÂN VIÊN
// -----------------------------
export async function POST(req: NextRequest) {
  try {
    const json = await req.json();
    const body = InsertNhanVienSchema.parse(json);
    console.log('body', body);

    const conn = await getConnection();

    try {
      await conn.query('CALL sp_InsertNhanVien(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [
        body.ID,
        body.CCCD,
        body.Ho,
        body.Ten,
        body.Dem ?? '',
        body.NgaySinh,
        body.GioiTinh,
        body.SoDienThoai,
        body.BenhVien_ID,
        body.Khoa_ID,
      ]);
      console.log('Inserted NhanVien with ID:', body.NgaySinh);
    } catch (err) {
      const e = err as MysqlError;
      return error(e.sqlMessage ?? e.message);
    } finally {
      conn.release();
    }

    return NextResponse.json({ success: true });
  } catch (err) {
    if (err instanceof z.ZodError) {
      const msg = err.errors.map((e) => e.message).join(', ');
      return error(msg);
    }
    const e = err as MysqlError;
    return error(e.message);
  }
}

// -----------------------------
// PUT: CẬP NHẬT NHÂN VIÊN
// -----------------------------
export async function PUT(req: NextRequest) {
  try {
    const json = await req.json();
    const body = UpdateNhanVienSchema.parse(json);

    const conn = await getConnection();

    try {
      await conn.query('CALL sp_UpdateNhanVien(?, ?, ?, ?)', [
        body.ID,
        body.SoDienThoai,
        body.Khoa_ID,
        body.BenhVien_ID,
      ]);
    } catch (err) {
      const e = err as MysqlError;
      return error(e.sqlMessage ?? e.message);
    } finally {
      conn.release();
    }

    return NextResponse.json({ success: true });
  } catch (err) {
    if (err instanceof z.ZodError) {
      const msg = err.errors.map((e) => e.message).join(', ');
      return error(msg);
    }
    const e = err as MysqlError;
    return error(e.message);
  }
}

// -----------------------------
// DELETE: XOÁ NHÂN VIÊN
// -----------------------------
export async function DELETE(req: NextRequest) {
  const id = req.nextUrl.searchParams.get('id');

  if (!id) return error('Thiếu ID để xoá nhân viên');

  const conn = await getConnection();

  try {
    await conn.query('CALL sp_DeleteNhanVien(?)', [id]);
  } catch (err) {
    const e = err as MysqlError;
    return error(e.sqlMessage ?? e.message);
  } finally {
    conn.release();
  }

  return NextResponse.json({ success: true });
}
