
def test_iris_netcdftime_compatibility_1():
    import iris, netcdftime
    t1 = netcdftime.datetime(1997, 2, 2, 1, 0, 0, 0, -1, 1)
    t2 = iris.time.PartialDateTime(year=1997)
    assert (t1 == t2)


def test_iris_netcdftime_compatibility_2():
    import cf_units
    from iris.time import PartialDateTime as PDT
    tu = cf_units.Unit('hours since 1970-01-01 0:0:0', calendar='360_day')
    pdt1 = PDT(1970, 2, 1, 0, 0, 0)
    tu.date2num(pdt1)

