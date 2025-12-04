import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { pool, MysqlError } from '@/lib/db';
import { RowDataPacket } from 'mysql2/promise';

// ===== ZOD SCHEMA KẾT QUẢ =====
export const AppointmentSchema = z.object({
  MaCuocHen: z.string(),
  TenBenhNhan: z.string(),
  NgayGio: z.string(), // ISO string
  TinhTrang: z.string(),
});

export type Appointment = z.infer<typeof AppointmentSchema>;

// Dữ liệu thô từ MySQL
interface DbAppointment extends RowDataPacket {
  MaCuocHen: number; // ch.ID là INT
  TenBenhNhan: string;
  NgayGio: Date; // DATETIME
  TinhTrang: string;
}

// Validate id
const ParamsSchema = z.object({
  id: z.string().min(1),
});

function error(message: string, status = 400) {
  return NextResponse.json({ success: false, message }, { status });
}

export async function GET(req: NextRequest) {
  try {
    // 1. Tự lấy id từ URL: /api/bacsi/BS00001/cuochen
    const pathname: string = new URL(req.url).pathname;
    const segments: string[] = pathname.split('/').filter(Boolean); // ["api","bacsi","BS00001","cuochen"]
    const idSegment: string | undefined = segments[2]; // index 2 = BS00001

    const { id } = ParamsSchema.parse({ id: idSegment });

    // 2. Gọi stored procedure
    const [rowsRaw] = await pool.query<RowDataPacket[][] | RowDataPacket[]>(
      'CALL sp_ListAppointments(?)',
      [id]
    );

    // 3. Lấy result set đầu tiên (CALL có thể trả nhiều set)
    let dbRows: DbAppointment[] = [];

    if (Array.isArray(rowsRaw)) {
      if (rowsRaw.length > 0 && Array.isArray(rowsRaw[0])) {
        dbRows = rowsRaw[0] as DbAppointment[];
      } else {
        dbRows = rowsRaw as DbAppointment[];
      }
    }

    // 4. Map sang kiểu gửi cho client
    const mapped: Appointment[] = dbRows.map((row) => ({
      MaCuocHen: String(row.MaCuocHen),
      TenBenhNhan: row.TenBenhNhan,
      NgayGio: row.NgayGio.toISOString(), // Date -> string
      TinhTrang: row.TinhTrang,
    }));

    // 5. Validate bằng Zod
    const parsed = z.array(AppointmentSchema).parse(mapped);

    return NextResponse.json({ success: true, data: parsed });
  } catch (err) {
    if (err instanceof z.ZodError) {
      const msg = err.errors.map((e) => e.message).join(', ');
      return error(`Dữ liệu không đúng định dạng: ${msg}`, 500);
    }
    const e = err as MysqlError;
    return error(e.sqlMessage ?? e.message, 500);
  }
}
