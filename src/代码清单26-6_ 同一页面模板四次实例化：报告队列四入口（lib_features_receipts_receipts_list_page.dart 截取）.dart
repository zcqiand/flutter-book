// ……（节略：列表页动作区前段（登出/数据录入等入口），见仓内原文）
          // M03.F05-F08.I01 队列入口（流程线第四至七环节：审核/批准/发放/归档）。
          IconButton(
            tooltip: '报告审核',
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    const ReportPhaseQueuePage(phase: FlowStatus.review),
              ),
            ),
          ),
          IconButton(
            tooltip: '报告批准',
            icon: const Icon(Icons.verified_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    const ReportPhaseQueuePage(phase: FlowStatus.approval),
              ),
            ),
          ),
          IconButton(
            tooltip: '报告发放',
            icon: const Icon(Icons.outbound),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    const ReportPhaseQueuePage(phase: FlowStatus.issuance),
              ),
            ),
          ),
          IconButton(
            tooltip: '报告归档',
            icon: const Icon(Icons.inventory_2_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) =>
                    const ReportPhaseQueuePage(phase: FlowStatus.archived),
              ),
            ),
          ),
// ……（节略：账户与登出入口，见仓内原文）