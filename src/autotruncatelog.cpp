//*****************************************************************************
//*****************************************************************************


#include "autotruncatelog.h"
#include "util.h"

int AutoTruncateLog::init(const std::string& sval, bool isServicenode)
{
    constexpr size_t ONE_MB{1024*1024};
    int rc{0};
    try {
        size_t bigSz{BIG_MB() * ONE_MB};
        size_t truncate_mb{(not sval.empty()
                       ? lexical_cast<size_t>(sval)
                       : (isServicenode
                          ? SERVICENODE_MB()
                          : NON_SERVICENODE_MB()))};
        if (not inRange(truncate_mb)) {
            rc = 1;
        } else {
            size_t newSz{bigSz - truncate_mb * ONE_MB};
            m_truncSz = TruncateSizes{bigSz,newSz};
            if (truncate_mb == 0)
                m_truncSz.disable();
        }
    } catch(...) {
        rc = 2;
    }
    return rc;
}

void AutoTruncateLog::check(size_t height)
{
    if (enabled() && checkNow(height)
        && (height == 0 || m_lastHeightChecked != height))
    {
        m_lastHeightChecked = height;
        TruncateLogKeepRecent(m_truncSz.bigSize(),m_truncSz.newSize());
    }
}
