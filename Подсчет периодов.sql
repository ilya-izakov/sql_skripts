select/* Разделение на периоды по датам и признаку*/
    nt.*
    ,(
    select
        min(nt_min.report_data)
    from
        new_table as nt_min
    where
        nt_min.schet = nt.schet
        and nt_min.debt_feature = nt.debt_feature
        and nt_min.report_data <= nt.report_data
        and nt_min.report_data >
        (
        select
            max(nt_.report_data)
        from
            new_table as nt_
        where
            nt_.schet = nt.schet
            and nt_.debt_feature != nt.debt_feature
            and nt_.report_data <= nt.report_data
        )
     ) as min_data
from
    new_table as nt
order
    by schet, report_data
	
	
	select
    nt.*
    ,(
    select
        min(nt_max.report_data)
    from
        new_table as nt_max
    where
        nt_max.schet = nt.schet
        and nt_max.debt_feature != nt.debt_feature
        and nt_max.report_data > nt.report_data
     ) as max_data
from
    new_table as nt
order by
    schet, report_data
	