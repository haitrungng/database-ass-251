// lib/db.ts
import mysql, { Pool, PoolOptions, PoolConnection } from 'mysql2/promise';

// -----------------------------
// MYSQL ERROR TYPE
// -----------------------------
export interface MysqlError extends Error {
  code?: string;
  errno?: number;
  sqlMessage?: string;
}

// -----------------------------
// MYSQL POOL CONFIG
// -----------------------------
const dbConfig: PoolOptions = {
  host: process.env.DB_HOST ?? '',
  user: process.env.DB_USER ?? '',
  password: process.env.DB_PASS ?? '',
  database: process.env.DB_NAME ?? '',
  waitForConnections: true,
  timezone: 'Z',
  connectionLimit: 10,
  queueLimit: 0,
};

// -----------------------------
// REUSE POOL (NEXT.JS SERVERLESS)
// -----------------------------
declare global {
  // Avoid TS error when attaching custom global variable
  // Must be typed as any here because global cannot know our type
  // This is the ONLY allowed any in the whole backend, otherwise TS will error
  // But we won't use `any` anywhere else in code
  var _mysqlPool: Pool | undefined;
}

if (!global._mysqlPool) {
  global._mysqlPool = mysql.createPool(dbConfig);
}

export const pool: Pool = global._mysqlPool;

// -----------------------------
// GET A CONNECTION (TYPED)
// -----------------------------
export async function getConnection(): Promise<PoolConnection> {
  return pool.getConnection();
}
