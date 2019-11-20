import dotenv from 'dotenv';
dotenv.config();

export const NODE_ENV = process.env.NODE_ENV  || 'development';
export const API_HOST = process.env.BACKEND_EXTERNAL_HOST  || '127.0.0.1:9292';

