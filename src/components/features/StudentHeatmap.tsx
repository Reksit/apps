import React, { useState } from 'react';
import { managementAPI } from '../../services/api';
import { useToast } from '../../contexts/ToastContext';
import { Search, Activity, MessageCircle, User } from 'lucide-react';

interface Student {
  id: string;
  name: string;
  email: string;
  className: string;
  department: string;
}

interface HeatmapData {
  heatmap: { [date: string]: { [activity: string]: number } };
  dailyTotals: { [date: string]: number };
}

const StudentHeatmap: React.FC = () => {
  const [searchEmail, setSearchEmail] = useState('');
  const [searchResults, setSearchResults] = useState<Student[]>([]);
  const [selectedStudent, setSelectedStudent] = useState<Student | null>(null);
  const [heatmapData, setHeatmapData] = useState<HeatmapData | null>(null);
  const [loading, setLoading] = useState(false);
  const [searchLoading, setSearchLoading] = useState(false);

  const { showToast } = useToast();

  const searchStudents = async () => {
    if (!searchEmail.trim()) {
      showToast('Please enter a student email', 'warning');
      return;
    }

    setSearchLoading(true);
    try {
      const response = await managementAPI.searchStudents(searchEmail);
      setSearchResults(response);
      
      if (response.length === 0) {
        showToast('No students found', 'info');
      }
    } catch (error: any) {
      showToast(error.message || 'Failed to search students', 'error');
    } finally {
      setSearchLoading(false);
    }
  };

  const selectStudent = async (student: Student) => {
    setSelectedStudent(student);
    setSearchResults([]);
    setSearchEmail('');
    setLoading(true);

    try {
      const response = await managementAPI.getStudentHeatmap(student.id);
      setHeatmapData(response.heatmap);
    } catch (error: any) {
      showToast(error.message || 'Failed to load student heatmap', 'error');
    } finally {
      setLoading(false);
    }
  };

  const getIntensityColor = (count: number) => {
    if (count === 0) return 'bg-gray-100 hover:bg-gray-200';
    if (count <= 2) return 'bg-green-200 hover:bg-green-300';
    if (count <= 4) return 'bg-green-400 hover:bg-green-500';
    if (count <= 6) return 'bg-green-600 hover:bg-green-700';
    return 'bg-green-800 hover:bg-green-900';
  };

  const generateCalendarGrid = () => {
    const weeks = [];
    const today = new Date();
    const startDate = new Date(today);
    startDate.setDate(startDate.getDate() - 364); // 52 weeks back
    
    // Start from Sunday of the week containing startDate
    const startDay = startDate.getDay();
    startDate.setDate(startDate.getDate() - startDay);
    
    for (let week = 0; week < 53; week++) {
      const weekDays = [];
      for (let day = 0; day < 7; day++) {
        const currentDate = new Date(startDate);
        currentDate.setDate(startDate.getDate() + (week * 7) + day);
        
        if (currentDate <= today) {
          weekDays.push(currentDate.toISOString().split('T')[0]);
        } else {
          weekDays.push(null);
        }
      }
      weeks.push(weekDays);
    }
    
    return weeks;
  };

  const getActivityTooltip = (date: string) => {
    if (!heatmapData || !heatmapData.heatmap[date]) return `${date}: No activity`;
    
    const activities = heatmapData.heatmap[date];
    const total = heatmapData.dailyTotals[date] || 0;
    
    let tooltip = `${date}: ${total} activities\n`;
    Object.entries(activities).forEach(([activity, count]) => {
      tooltip += `${activity.replace('_', ' ')}: ${count}\n`;
    });
    
    return tooltip.trim();
  };

  const monthLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  const dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  return (
    <div className="space-y-6">
      <div className="flex items-center space-x-2">
        <Activity className="h-6 w-6 text-purple-600" />
        <h2 className="text-xl font-semibold">Student Activity Heatmap</h2>
      </div>

      {/* Search Section */}
      <div className="bg-white rounded-xl shadow-sm border p-6">
        <h3 className="font-semibold mb-4">Search Student</h3>
        <div className="flex space-x-3">
          <input
            type="email"
            value={searchEmail}
            onChange={(e) => setSearchEmail(e.target.value)}
            placeholder="Enter student email"
            className="flex-1 p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-purple-500 focus:border-purple-500"
            onKeyPress={(e) => e.key === 'Enter' && searchStudents()}
          />
          <button
            onClick={searchStudents}
            disabled={searchLoading}
            className="bg-purple-600 text-white px-6 py-3 rounded-lg hover:bg-purple-700 disabled:opacity-50 transition-colors flex items-center space-x-2"
          >
            <Search className="h-5 w-5" />
            <span>{searchLoading ? 'Searching...' : 'Search'}</span>
          </button>
        </div>

        {/* Search Results */}
        {searchResults.length > 0 && (
          <div className="mt-4 space-y-2">
            <h4 className="font-medium">Search Results</h4>
            {searchResults.map((student) => (
              <button
                key={student.id}
                onClick={() => selectStudent(student)}
                className="w-full text-left p-3 border border-gray-200 rounded-lg hover:border-purple-300 hover:bg-purple-50 transition-colors"
              >
                <div className="flex items-center space-x-3">
                  <div className="w-10 h-10 bg-purple-600 rounded-full flex items-center justify-center">
                    <User className="h-5 w-5 text-white" />
                  </div>
                  <div className="flex-1">
                    <div className="font-medium">{student.name}</div>
                    <div className="text-sm text-gray-600">{student.email}</div>
                    <div className="text-xs text-gray-500">
                      {student.className} • {student.department}
                    </div>
                  </div>
                </div>
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Student Heatmap */}
      {selectedStudent && (
        <div className="bg-white rounded-xl shadow-sm border p-6">
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="text-lg font-semibold">{selectedStudent.name}</h3>
              <p className="text-gray-600">{selectedStudent.email}</p>
              <p className="text-sm text-gray-500">
                {selectedStudent.className} • {selectedStudent.department}
              </p>
            </div>
            <button className="bg-purple-600 text-white p-2 rounded-lg hover:bg-purple-700 transition-colors">
              <MessageCircle className="h-5 w-5" />
            </button>
          </div>

          {loading ? (
            <div className="flex items-center justify-center h-32">
              <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-purple-600"></div>
            </div>
          ) : heatmapData ? (
            <div className="space-y-6">
              <div className="flex items-center justify-between">
                <h4 className="font-medium">Activity Heatmap (Last 365 Days)</h4>
                <div className="flex items-center space-x-2 text-sm text-gray-600">
                  <span>Less</span>
                  <div className="flex space-x-1">
                    <div className="w-3 h-3 bg-gray-100 rounded-sm border"></div>
                    <div className="w-3 h-3 bg-green-200 rounded-sm"></div>
                    <div className="w-3 h-3 bg-green-400 rounded-sm"></div>
                    <div className="w-3 h-3 bg-green-600 rounded-sm"></div>
                    <div className="w-3 h-3 bg-green-800 rounded-sm"></div>
                  </div>
                  <span>More</span>
                </div>
              </div>

              {/* Professional GitHub-style Heatmap */}
              <div className="overflow-x-auto bg-gray-50 p-4 rounded-lg">
                <div className="flex">
                  {/* Day labels */}
                  <div className="flex flex-col justify-between mr-2 text-xs text-gray-500 h-24">
                    <div></div>
                    <div>Mon</div>
                    <div></div>
                    <div>Wed</div>
                    <div></div>
                    <div>Fri</div>
                    <div></div>
                  </div>

                  {/* Calendar grid */}
                  <div className="flex-1">
                    {/* Month labels */}
                    <div className="flex mb-2">
                      {generateCalendarGrid().map((week, weekIndex) => {
                        const firstDay = week.find(day => day !== null);
                        if (!firstDay) return <div key={weekIndex} className="w-3 mr-1"></div>;
                        
                        const date = new Date(firstDay);
                        const isFirstWeekOfMonth = date.getDate() <= 7;
                        
                        return (
                          <div key={weekIndex} className="w-3 mr-1 text-xs text-gray-500">
                            {isFirstWeekOfMonth ? monthLabels[date.getMonth()] : ''}
                          </div>
                        );
                      })}
                    </div>

                    {/* Heatmap grid */}
                    <div className="flex">
                      {generateCalendarGrid().map((week, weekIndex) => (
                        <div key={weekIndex} className="flex flex-col mr-1">
                          {week.map((date, dayIndex) => {
                            if (!date) {
                              return <div key={dayIndex} className="w-3 h-3 mb-1"></div>;
                            }
                            
                            const count = heatmapData.dailyTotals[date] || 0;
                            return (
                              <div
                                key={dayIndex}
                                className={`w-3 h-3 mb-1 rounded-sm border border-gray-200 cursor-pointer transition-colors ${getIntensityColor(count)}`}
                                title={getActivityTooltip(date)}
                              />
                            );
                          })}
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              {/* Activity Legend */}
              <div className="p-4 bg-gray-50 rounded-lg">
                <h5 className="font-medium mb-3">Activity Types</h5>
                <div className="grid grid-cols-2 md:grid-cols-3 gap-3 text-sm">
                  <div className="flex items-center space-x-2">
                    <div className="w-4 h-4 bg-blue-400 rounded-sm"></div>
                    <span>AI Assessment</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <div className="w-4 h-4 bg-green-400 rounded-sm"></div>
                    <span>Class Assessment</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <div className="w-4 h-4 bg-purple-400 rounded-sm"></div>
                    <span>AI Chat</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <div className="w-4 h-4 bg-yellow-400 rounded-sm"></div>
                    <span>Task Management</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <div className="w-4 h-4 bg-red-400 rounded-sm"></div>
                    <span>Alumni Chat</span>
                  </div>
                  <div className="flex items-center space-x-2">
                    <div className="w-4 h-4 bg-indigo-400 rounded-sm"></div>
                    <span>Professor Chat</span>
                  </div>
                </div>
              </div>

              {/* Activity Statistics */}
              <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
                <div className="bg-blue-50 p-4 rounded-lg text-center">
                  <div className="text-2xl font-bold text-blue-600">
                    {Object.values(heatmapData.dailyTotals).reduce((a, b) => a + b, 0)}
                  </div>
                  <div className="text-sm text-gray-600">Total Activities</div>
                </div>
                <div className="bg-green-50 p-4 rounded-lg text-center">
                  <div className="text-2xl font-bold text-green-600">
                    {Object.keys(heatmapData.dailyTotals).filter(date => heatmapData.dailyTotals[date] > 0).length}
                  </div>
                  <div className="text-sm text-gray-600">Active Days</div>
                </div>
                <div className="bg-purple-50 p-4 rounded-lg text-center">
                  <div className="text-2xl font-bold text-purple-600">
                    {Math.max(...Object.values(heatmapData.dailyTotals), 0)}
                  </div>
                  <div className="text-sm text-gray-600">Max Daily</div>
                </div>
                <div className="bg-yellow-50 p-4 rounded-lg text-center">
                  <div className="text-2xl font-bold text-yellow-600">
                    {(Object.values(heatmapData.dailyTotals).reduce((a, b) => a + b, 0) / 365).toFixed(1)}
                  </div>
                  <div className="text-sm text-gray-600">Daily Average</div>
                </div>
              </div>
            </div>
          ) : (
            <div className="text-center py-8 text-gray-500">
              <Activity className="h-12 w-12 mx-auto mb-4 text-gray-300" />
              <p>No activity data available for this student.</p>
            </div>
          )}
        </div>
      )}

      {!selectedStudent && (
        <div className="bg-white rounded-xl shadow-sm border p-8 text-center">
          <Activity className="h-16 w-16 text-gray-300 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">Select a Student</h3>
          <p className="text-gray-600">Search for a student to view their activity heatmap and engagement patterns.</p>
        </div>
      )}
    </div>
  );
};

export default StudentHeatmap;