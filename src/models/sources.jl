const DataSource = ModelType("DataSource";
    abstract = true,
)

const ColumnarDataSource = ModelType("ColumnarDataSource";
    abstract = true,
    bases = [DataSource],
)

const ColumnDataSource = ModelType("ColumnDataSource";
    bases = [ColumnarDataSource],
    props = [
        :data => ColumnDataT(),
        :column_names => GetSetT(x->collect(String,keys(x.data))),
    ],
)

const CDSView = ModelType("CDSView";
    props = [
        :filters => ListT(AnyT()),
        :source => InstanceT(ColumnarDataSource),
    ],
)
