<#compress>
    <#escape x as x?html>
        <#include "../common/macro.ftl">
<!-- freemarker macros have to be imported into a namespace. We strongly
recommend sticking to 'spring' -->
        <#import "/spring.ftl" as spring/>
<!DOCTYPE html>
<html lang="zh">
<head>
    <@meta />

    <script type="text/javascript" src="/dist/js/jquery.min.js"></script>
    <link type="text/css" rel="stylesheet" media="all" href="/dist/css/bootstrap.min.css"/>
    <script type="text/javascript" src="/dist/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="/dist/js/vue.js"></script>

    <script type="text/javascript">
        function checkInput() {
            var text = $("#income").val();
            if (text == null || text == "") {
                $("#calcBtn1st").attr("disabled", "true");
            } else {
                $("#calcBtn1st").removeAttr("disabled");
            }
        }
    </script>
</head>
<body>
<div id="app" class="container">
    <p></p>
    <div class="panel panel-info">
        <div class="panel-heading" data-toggle="collapse" data-parent="#accordion" href="#collapseOne"
             aria-expanded="true" aria-controls="collapseOne">个税计算器
        </div>
        <div class="panel-body" id="collapseOne" class="panel-collapse collapse in" role="tabpanel"
             aria-labelledby="headingOne">
            <fieldset>
                <div class="col-xs-4">
                    <input type="number" min="0" step="0.01" name="income" class="form-control"
                           placeholder="月薪（不含免税项，如五险一金）" id="income" onmouseleave="checkInput()"
                           v-model="income" oninput="checkInput()"/>
                </div>
                <input type="submit" value="计算" class="btn btn-primary" id="calcBtn1st" @click="calcPrivTax"
                       disabled/>
            </fieldset>

            <div v-if="isFirstVisible">
                <br>
                <p>收入：{{incomeResult}} 交税：{{taxes}}</p>
                <table class="table table-bordered table-hover">
                    <tr>
                        <th>税率</th>
                        <th>区间</th>
                        <th>速扣数</th>
                    </tr>
                    <tr>
                        <td>{{taxRate.rate}}</td>
                        <td>[{{taxRate.rangeLowest}}, {{taxRate.rangeHighest}})</td>
                        <td>{{taxRate.quickDeduction}}</td>
                    </tr>
                </table>
            </div>
        </div>
    </div>

<#--<HR>-->

    <div class="panel panel-info">
        <div class="panel-heading" data-toggle="collapse" data-parent="#accordion" href="#collapseTwo"
             aria-expanded="true" aria-controls="collapseTwo">个税统筹
        </div>
        <div class="panel-body" id="collapseTwo" class="panel-collapse collapse in" role="tabpanel"
             aria-labelledby="headingTwo">
            <#--<form name="tax_avoidance" class="form-horizontal" role="form">-->
                <div class="form-group">
                    <label for="estimatedAnnualSalary" class="col-sm-2 control-label">预估总年薪</label>
                    <div class="col-sm-10">
                        <input type="number" min="0" step="0.01" class="form-control" id="estimatedAnnualSalary"
                               name="estimatedAnnualSalary" v-model="estimatedAnnualSalary">
                    </div>
                </div>
                <div class="form-group">
                    <label for="alreadyPaidSalary" class="col-sm-2 control-label">已发薪酬</label>
                    <div class="col-sm-10">
                        <input type="number" min="0" step="0.01" class="form-control" id="alreadyPaidSalary"
                               name="alreadyPaidSalary" min="1" v-model="alreadyPaidSalary">
                    </div>
                </div>
                <div class="form-group">
                    <label for="remainingMonths" class="col-sm-2 control-label">本年剩余月薪发放次数</label>
                    <div class="col-sm-10">
                        <input type="number" class="form-control" id="remainingMonths" name="remainingMonths"
                               min="0" max="12" v-model="remainingMonths">
                    </div>
                </div>
                <div class="form-group">
                    <div class="col-sm-offset-2 col-sm-10">
                        <button type="submit" class="btn btn-primary" @click="optTaxPlan">筹划</button>
                    </div>
                </div>
            <#--</form>-->

            <div v-if="isPlanVisible">
                <br>
                <p>月薪（税前）：{{taxplan.preTaxSalary}}</p>
                <p>月纳税额：{{taxplan.salaryTaxes}}</p>
                <p>年终奖（税前）：{{taxplan.preTaxBonus}}</p>
                <p>年终奖纳税额：{{taxplan.bonusTaxes}}</p>
                <p>全年总纳税额：{{taxplan.totalTaxes}}</p>
                <table class="table table-bordered table-hover">
                    <caption>适用税率</caption>
                    <tr>
                        <th>税率</th>
                        <th>区间</th>
                        <th>速扣数</th>
                    </tr>
                    <tr>
                        <td>{{taxplan.salaryTaxRate.rate}}</td>
                        <td>[{{taxplan.salaryTaxRate.rangeLowest}}, {{taxplan.salaryTaxRate.rangeHighest}})</td>
                        <td>{{taxplan.salaryTaxRate.quickDeduction}}</td>
                    </tr>
                </table>
            </div>
        </div>
    </div>
</div>
</body>
<script type="text/javascript">
    new Vue({
        el: '#app',
        data: function () {
            return {
                result: '',
                income: '',
                incomeResult: '',
                isFirstVisible: false,
                taxes: '',
                taxRate: {
                    id: 0,
                    rate: 0,
                    rangeLowest: 0,
                    rangeHighest: 0,
                    quickDeduction: 0
                },
                estimatedAnnualSalary: '',
                alreadyPaidSalary: '',
                remainingMonths: '',
                isPlanVisible: false,
                taxplan: {
                    preTaxSalary: 0,
                    preTaxBonus: 0,
                    taxableSalary: 0,
                    taxableBonus: 0,
                    salaryTaxRate: {
                        id: 0,
                        rate: 0,
                        rangeLowest: 0,
                        rangeHighest: 0,
                        quickDeduction: 0
                    },
                    bonusTaxRate: {
                        id: 0,
                        rate: 0,
                        rangeLowest: 0,
                        rangeHighest: 0,
                        quickDeduction: 0
                    },
                    salaryTaxes: 0,
                    bonusTaxes: 0,
                    totalTaxes: 0,
                },
            }
        },
        methods: {
            calcPrivTax() {
                var self = this;
                $.ajax({
                    type: "get",
                    url: "/tax/calc_tax",
                    data: {"income": self.income},
                    success: function (result) {
                        self.isFirstVisible = true;
                        self.incomeResult = self.income;
                        self.taxes = result.taxes;
                        self.taxRate = result.taxrate;
                    }
                });
            },
            optTaxPlan() {
                var self = this;
                $.ajax({
                    type: "post",
                    url: "/tax/opt_plan",
                    data: {
                        "estimatedAnnualSalary": self.estimatedAnnualSalary,
                        "alreadyPaidSalary": self.alreadyPaidSalary,
                        "remainingMonths": self.remainingMonths
                    },
                    success: function (result) {
                        self.isPlanVisible = true;
                        self.taxplan = result.taxplan;
                    }
                });
            }
        },
        beforeMount() {
            // this.initConfigList();
        }
    });
</script>
</html>
    </#escape>
</#compress>