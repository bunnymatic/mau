export declare type Column = {
    id: string;
    align: 'left' | 'right';
};
export declare type Table = {
    rows: Array<Array<string>>;
    columns: Array<Column>;
};
export default function printTable(table: Table, buffer?: string): string;
