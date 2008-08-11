# Author: Daryl Harrison

# Enthought library imports.
from enthought.traits.api import Instance, String, List, Int
from enthought.traits.ui.api import View, Item
from enthought.tvtk.api import tvtk

# Local imports.
from enthought.mayavi.core.file_data_source import FileDataSource
from enthought.mayavi.core.pipeline_info import PipelineInfo
from enthought.mayavi.core.traits import DEnum
from os import path
from numpy import loadtxt, array

######################################################################
# `TriangleReader` class
######################################################################
class TriangleReader(FileDataSource):
    """
    Reader for the Triangle file format: <http://tetgen.berlios.de/fformats.html>
    Outputs an unstructured grid dataset.
    Open the .face file to construct a surface mesh comprised of triangles.
    Open the .ele file to construct a solid mesh comprised of tetrahedra.
    """

    # The version of this class.  Used for persistence.
    __version__ = 0

    # The VTK dataset to manage.
    _grid = Instance(tvtk.UnstructuredGrid, args=(), allow_none=False)
    _basename = String
    _numbered_from = Int

    # Information about what this object can produce.
    output_info = PipelineInfo(datasets=['unstructured_grid'],
                               attribute_types=['any'],
                               attributes=['any'])

    point_scalars_name = DEnum(values_name='_point_scalars_list',
                               desc='scalar point data attribute to use')

    cell_scalars_name = DEnum(values_name='_cell_scalars_list',
                               desc='scalar cell data attribute to use')

    _cell_scalars_list = List(String)
    _point_scalars_list = List(String)

    _assign_attribute = Instance(tvtk.AssignAttribute, args=(), allow_none=False)

    ########################################
    # The view

    view = View(Item(name='point_scalars_name'),
                Item(name='cell_scalars_name'))

    ########################################
    # `FileDataSource` interface

    def initialize(self, base_file_name):
        split = path.splitext(base_file_name)
        self._basename = split[0]
        extension = split[1]

        self._grid.points = tvtk.Points()
        self._assign_attribute.input = self._grid

        self.read_node_file()
        if (extension == '.face'):
            self.read_face_file()
        else:
            self.read_ele_file()

        self.outputs = [self._assign_attribute.output]
        self.name = 'Triangle file (%s%s)' %(path.basename(self._basename), extension)

    ########################################
    # File reading methods

    def read_node_file(self):
        file_name = '%s.node' %self._basename

        file = open(file_name)
        first_line, line_number = self.read_first_line(file)
        second_line_number = self.get_second_line_number(line_number, file)
        file.close()

        points, dimensions, attributes, boundary_marker = map(int, first_line)

        # Load all data into array
        data_array = loadtxt(file_name, skiprows=second_line_number-1)

        self._numbered_from = int(data_array[0][0])

        points_array = data_array[:, 1:(1+dimensions)]
        map(self._grid.points.insert_next_point, points_array)

        for i in range(attributes):
            attribute_array = data_array[:, (i+dimensions+1):(i+dimensions+2)]
            self.add_attribute_array(attribute_array, i, 'point')

        if (boundary_marker):
            boundary_marker_array = data_array[:, (dimensions+attributes+1):(dimensions+attributes+2)]
            self.add_boundary_marker_array(boundary_marker_array, 'point')


    def read_face_file(self):
        file_name = '%s.face' %self._basename

        file = open(file_name)
        first_line, line_number = self.read_first_line(file)
        second_line_number = self.get_second_line_number(line_number, file)
        file.close()

        faces, boundary_marker = map(int, first_line)

        # Load all data into array
        data_array = loadtxt(file_name, skiprows=second_line_number-1)

        nodes_array = data_array[:, 1:4]
        # 5 is cell type for triangles
        map(lambda x:self.insert_cell(x, 5), nodes_array)

        if (boundary_marker):
            boundary_marker_array = data_array[:, 4:5]
            self.add_boundary_marker_array(boundary_marker_array, 'cell')


    def read_ele_file(self):
        file_name = '%s.ele' %self._basename

        file = open(file_name)
        first_line, line_number = self.read_first_line(file)
        second_line_number = self.get_second_line_number(line_number, file)
        file.close()

        tetrahedra, nodes_per_tetrahedron, attributes =  map(int, first_line)

        # Load all data into array
        data_array = loadtxt(file_name, skiprows=second_line_number-1)

        nodes_array = data_array[:, 1:(nodes_per_tetrahedron+1)]
        # 10 is cell type for tetrahedra
        map(lambda x:self.insert_cell(x, 10), nodes_array)

        for i in range(attributes):
            attribute_array = data_array[:, (i+nodes_per_tetrahedron+1):(i+nodes_per_tetrahedron+2)]
            self.add_attribute_array(attribute_array, i, 'cell')


    def insert_cell(self, nodes_array, cell_type):
        #ids = tvtk.IdList()
        nodes_array = array(map(lambda x:int(x-self._numbered_from), nodes_array))
        #ids.from_array(nodes_array)
        self._grid.insert_next_cell(cell_type, nodes_array)


    def add_attribute_array(self, attribute_array, i, type):
        attribute_array_name = 'Attribute %i' %i
        if (type == 'cell'): # .ele file attributes are of type Int
            tvtk_attribute_array = tvtk.IntArray(name=attribute_array_name)
            attribute_array = map(int, attribute_array)
        else:                # .node file attributes are of type Float
            tvtk_attribute_array = tvtk.FloatArray(name=attribute_array_name)
        tvtk_attribute_array.from_array(attribute_array)
        getattr(self._grid, '%s_data' %type).add_array(tvtk_attribute_array)
        getattr(self, '_%s_scalars_list' %type).append(attribute_array_name)

        if (i == 0):
            self._set_data_name(type, 'Attribute 0')


    def add_boundary_marker_array(self, boundary_marker_array, type):
        boundary_marker_array_name = 'Boundary Marker'
        tvtk_boundary_marker_array = tvtk.IntArray(name=boundary_marker_array_name)
        tvtk_boundary_marker_array.from_array(boundary_marker_array)
        getattr(self._grid, '%s_data' %type).add_array(tvtk_boundary_marker_array)
        getattr(self, '_%s_scalars_list' %type).append(boundary_marker_array_name)
        self._set_data_name(type, 'Boundary Marker')


    def read_first_line(self, file):
        first_line = self.read_line(file)
        line_number = 1
        while (not first_line):
            first_line = self.read_line(file)
            line_number += 1
        return first_line, line_number


    def get_second_line_number(self, line_number, file):
        second_line = self.read_line(file)
        line_number += 1
        while (not second_line):
            second_line = self.read_line(file)
            line_number += 1
        return line_number


    def read_line(self, file):
        return file.readline().partition('#')[0].split()


    # Taken and modified from SetActiveAttribute filter:

    def _point_scalars_name_changed(self, value):
        self._set_data_name('point', value)


    def _cell_scalars_name_changed(self, value):
        self._set_data_name('cell', value)


    def _set_data_name(self, attr_type, value):
        if value is None:
            return

        if (attr_type == 'point'):
            data = self._grid.point_data
            other_data = self._grid.cell_data
        else:
            data = self._grid.cell_data
            other_data = self._grid.point_data

        method = getattr(data, 'set_active_scalars')
        method(value)

        # Deactivate other attribute
        method = getattr(other_data, 'set_active_scalars')
        method(None)

        self._assign_attribute.assign(value, 'SCALARS', attr_type.upper()+'_DATA')
        self._assign_attribute.update()
        # Fire an event, so the changes propagate
        self.data_changed = True