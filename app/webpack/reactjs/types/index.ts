// Put all types in here until it gets unweildy.
// Then we can bust it into smaller files and import them here
// so consumers can stay the same.

export interface OpenStudiosEventType {
  id: number;
  key: string;
  title: string;
  startDate: Date;
  startTime: string;
  endDate: Date;
  endTime: string;
  createdAt: Date;
  updatedAt: Date;
}
