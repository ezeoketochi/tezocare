export interface StaffNotification {
  id: string;
  type: string;
  title: string;
  message: string;
  status: string;
  patient_id: string | null;
  patient_name: string | null;
  created_at: string;
  read_at: string | null;
}

export interface NotificationsResult {
  notifications: StaffNotification[];
  unread_count: number;
}
