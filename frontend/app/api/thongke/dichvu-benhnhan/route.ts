import { NextRequest, NextResponse } from 'next/server';
import { z } from 'zod';
import { pool, MysqlError } from '@/lib/db';
import { RowDataPacket } from 'mysql2/promise';

// ===== SCHEMA GỬI RA CLIENT =====
export const ServiceUsageSchema = z.object({
  ID: z.string(), // UI dùng string
  HoTen: z.string(),
  SoLanSuDung: z.number(),
});

export type ServiceUsage = z.infer<typeof ServiceUsageSchema>;

// Dữ liệu thô từ MySQL
interface DbServiceUsage extends RowDataPacket {
  ID: number; // BenhNhan.ID là INT
  HoTen: string;
  SoLanSuDung: number;
}

// Query param ?min=...
const QuerySchema = z.object({
  min: z.coerce.number().int().min(1).default(1),
});

function error(message: string, status = 400) {
  return NextResponse.json({ success: false, message }, { status });
}

export async function GET(req: NextRequest) {
  try {
    const searchParams = req.nextUrl.searchParams;
    const minRaw: string | null = searchParams.get('min');

    const { min } = QuerySchema.parse({ min: minRaw ?? '1' });

    // Gọi SP
    const [rowsRaw] = await pool.query<RowDataPacket[][] | RowDataPacket[]>(
      'CALL sp_DichVuTheoBenhNhan(?)',
      [min]
    );

    let dbRows: DbServiceUsage[] = [];

    if (Array.isArray(rowsRaw)) {
      if (rowsRaw.length > 0 && Array.isArray(rowsRaw[0])) {
        dbRows = rowsRaw[0] as DbServiceUsage[];
      } else {
        dbRows = rowsRaw as DbServiceUsage[];
      }
    }

    // Map ID (number) -> string cho đúng với schema/UI
    const mapped: ServiceUsage[] = dbRows.map((row) => ({
      ID: String(row.ID),
      HoTen: row.HoTen,
      SoLanSuDung: row.SoLanSuDung,
    }));

    const parsed = z.array(ServiceUsageSchema).parse(mapped);

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
